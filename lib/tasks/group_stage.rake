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

  desc "Renumber group-stage matches in chronological order of kickoff (tiebreak: group letter)"
  task renumber_chronologically: :environment do
    ordered = Match.joins(:group).order(:kickoff_at, "groups.letter").to_a

    ActiveRecord::Base.transaction do
      # Pass 1: park every match at a non-colliding negative number to free up 1..72.
      ordered.each_with_index do |m, idx|
        m.update_column(:number, -(idx + 1))
      end
      # Pass 2: assign the final chronological number.
      ordered.each_with_index do |m, idx|
        m.update_column(:number, idx + 1)
      end
    end

    puts "Renumbered #{ordered.size} matches."
  end
end
