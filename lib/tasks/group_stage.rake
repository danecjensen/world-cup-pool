require Rails.root.join("db/group_stage_schedule")

namespace :group_stage do
  desc "Apply the official group-stage schedule (kickoffs, venues, home/away) to existing matches"
  task apply_schedule: :environment do
    central = ActiveSupport::TimeZone["Central Time (US & Canada)"]
    updated = 0

    ActiveRecord::Base.transaction do
      GROUP_STAGE_SCHEDULE.each do |row|
        group = Group.find_by!(letter: row[:group])
        home  = Team.find_by!(code: row[:home])
        away  = Team.find_by!(code: row[:away])

        match = Match.where(group_id: group.id)
                     .where("(home_team_id = ? AND away_team_id = ?) OR (home_team_id = ? AND away_team_id = ?)",
                            home.id, away.id, away.id, home.id)
                     .first

        unless match
          raise "No existing match found for #{row[:group]} #{row[:home]} vs #{row[:away]}"
        end

        kickoff = central.local(*row[:kickoff])
        match.update!(
          home_team_id: home.id,
          away_team_id: away.id,
          kickoff_at:   kickoff,
          venue:        row[:venue]
        )
        updated += 1
      end
    end

    puts "Applied schedule to #{updated} matches."
  end
end
