# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AssemblyMemberPresenter, type: :helper do
    let(:age) { 25 }
    let(:day_offset) { 0 }
    let(:today) { ::Time.zone.today }
    let(:birthday) { ::Date.new(today.year - age, today.month, today.day + day_offset) }

    let(:assembly_member) do
      build(:assembly_member, full_name: "Full name", birthday: birthday)
    end

    describe "age" do
      subject { described_class.new(assembly_member).age }

      context "when birthday was yesterday" do
        let(:day_offset) { -1 }

        it { is_expected.to eq(age) }
      end

      context "when birthday is today" do
        it { is_expected.to eq(age) }
      end

      context "when birthday is tomorrow" do
        let(:day_offset) { +1 }

        it { is_expected.to eq(age - 1) }
      end

      context "when birtday is not present" do
        let(:birthday) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe "gender" do
      subject { described_class.new(assembly_member).gender }

      it { is_expected.to eq t(assembly_member.gender, scope: "decidim.admin.models.assembly_member.genders") }
    end

    describe "name" do
      subject { described_class.new(assembly_member).name }

      it { is_expected.to eq "Full name" }

      context "when member is an existing user" do
        let(:user) { build(:user) }
        let(:assembly_member) { build(:assembly_member, full_name: "Full name", user: user) }

        it { is_expected.to eq ::Decidim::UserPresenter.new(user).name }
      end
    end

    describe "nickname" do
      subject { described_class.new(assembly_member).nickname }

      it { is_expected.to be_nil }

      context "when member is an existing user" do
        let(:user) { build(:user) }
        let(:assembly_member) { build(:assembly_member, user: user) }

        it { is_expected.to eq ::Decidim::UserPresenter.new(user).nickname }
      end
    end

    describe "personal_information" do
      subject { described_class.new(assembly_member).personal_information }

      it { is_expected.to eq "#{t(assembly_member.gender, scope: "decidim.admin.models.assembly_member.genders")} / #{age}" }

      context "when origin is present" do
        let(:assembly_member) { build(:assembly_member, birthday: birthday, origin: "World") }

        it { is_expected.to eq "#{t(assembly_member.gender, scope: "decidim.admin.models.assembly_member.genders")} / #{age} / World" }
      end

      context "when gender is not present" do
        let(:assembly_member) { build(:assembly_member, birthday: birthday, gender: nil) }

        it { is_expected.to eq age.to_s }
      end

      context "when birthday is not present" do
        let(:assembly_member) { build(:assembly_member, birthday: nil) }

        it { is_expected.to eq t(assembly_member.gender, scope: "decidim.admin.models.assembly_member.genders") }
      end

      context "when any property is present" do
        let(:assembly_member) { build(:assembly_member, gender: nil, birthday: nil, origin: nil) }

        it { is_expected.to eq "" }
      end
    end

    describe "position" do
      subject { described_class.new(assembly_member).position }

      context "when position is predefined" do
        it { is_expected.to eq t(assembly_member.position, scope: "decidim.admin.models.assembly_member.positions") }
      end

      context "when position is other" do
        let(:assembly_member) { build(:assembly_member, position: "other", position_other: "Custom position") }

        it "show the custom position value" do
          expect(subject).to eq("Custom position")
        end
      end
    end
  end
end
