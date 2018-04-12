# frozen_string_literal: true

module Decidim
  module Meetings
    module AdminLog
      # This class holds the logic to present a `Decidim::Meetings::Minute`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    MeetingPresenter.new(action_log, view_helpers).present
      class MinutePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :i18n,
            video_url: :string,
            audio_url: :string,
            is_visible: :boolean
          }
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.meetings.admin_log.minute.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.minute"
        end
      end
    end
  end
end
