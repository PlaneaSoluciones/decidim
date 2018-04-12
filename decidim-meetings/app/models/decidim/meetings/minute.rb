# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Minute in the Decidim::Meetings component.

    class Minute < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::MinutePresenter
      end

      def component
        meeting.component if meeting.respond_to?(:component)
      end
    end
  end
end
