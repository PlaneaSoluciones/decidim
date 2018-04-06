class CreateMeetingsMinutes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_meetings_minutes do |t|
      t.references :decidim_meeting, index: true
      t.jsonb :description
      t.string :video_url
      t.string :audio_url
      t.boolean :is_visible

      t.timestamps
    end
  end
end
