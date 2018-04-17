# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CreateMeeting do
    subject { described_class.new(form) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:current_user) { create :user, :admin, :confirmed, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:address) { "address" }
    let(:invalid) { false }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 1.day.from_now }
    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        location: { en: "location" },
        location_hints: { en: "location_hints" },
        start_time: start_time,
        end_time: 1.day.from_now + 1.hour,
        address: address,
        latitude: latitude,
        longitude: longitude,
        scope: scope,
        category: category,
        current_user: current_user,
        current_component: current_component
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:meeting) { Meeting.last }

      it "creates the meeting" do
        expect { subject.call }.to change(Meeting, :count).by(1)
      end

      it "sets the scope" do
        subject.call
        expect(meeting.scope).to eq scope
      end

      it "sets the category" do
        subject.call
        expect(meeting.category).to eq category
      end

      it "sets the component" do
        subject.call
        expect(meeting.component).to eq current_component
      end

      it "sets the longitude and latitude" do
        subject.call
        last_meeting = Meeting.last
        expect(last_meeting.latitude).to eq(latitude)
        expect(last_meeting.longitude).to eq(longitude)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Meeting, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "schedules a upcoming meeting notification job 48h before start time" do
        expect(Decidim.traceability)
          .to receive(:create!)
          .and_return(instance_double(Meeting, id: 1, start_time: start_time, participatory_space: participatory_process))

        expect(UpcomingMeetingNotificationJob)
          .to receive(:generate_checksum).and_return "1234"

        expect(UpcomingMeetingNotificationJob)
          .to receive_message_chain(:set, :perform_later) # rubocop:disable RSpec/MessageChain
          .with(set: start_time - 2.days).with(1, "1234")

        allow(Decidim::EventsManager).to receive(:publish).and_return(true)

        subject.call
      end

      it "sends a notification to the participatory space followers" do
        follower = create(:user, organization: organization)
        create(:follow, followable: participatory_process, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.meetings.meeting_created",
            event_class: Decidim::Meetings::CreateMeetingEvent,
            resource: kind_of(Meeting),
            recipient_ids: [follower.id]
          )

        subject.call
      end
    end
  end
end
