# 2026 FIFA World Cup Pool

A Rails 7 + Postgres pool app for the 2026 FIFA World Cup. Open registration, single shared pool, admin role for entering results.

## Tournament & scoring

- 48 teams in 12 groups of 4 (Dec 2025 draw seeded)
- 72 group games + 31 knockout matches (R32 → R16 → QF → SF → Final)
- Group pick = W/L/T per game. **1 point** per correct pick.
- Knockout = full bracket filled in up front. **R32 = 2, R16 = 3, QF = 4, SF = 5, Final = 6**.
- Group picks lock at first group kickoff. Bracket picks lock at first R32 kickoff. No late picks.
- Standings: total points, descending. Ties stay tied.

## Stack

- Rails 7.2, Ruby 3.3
- Postgres
- Devise (email + password)
- Hotwire / Turbo + Tailwind CSS
- Server-rendered

## Local development

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev   # foreman: rails server + tailwind watch
```

To create an admin user locally:

```ruby
User.create!(email: "you@example.com", password: "...", display_name: "You", admin: true)
```

## Deploy to Heroku

```bash
heroku create
heroku addons:create heroku-postgresql:essential-0
heroku addons:create sendgrid:starter
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key) \
                   ADMIN_EMAIL=you@example.com \
                   ADMIN_PASSWORD=changeme \
                   ADMIN_DISPLAY_NAME=Commissioner \
                   APP_HOST=your-app.herokuapp.com \
                   MAIL_FROM=no-reply@yourdomain.com
git push heroku main
heroku run rails db:seed
```

The included `app.json` and `Procfile` configure the release phase to run `db:prepare` and the postdeploy hook to seed teams/groups/fixtures.

## Email (password reset)

Devise's "Forgot your password?" flow emails a reset link. In production this is
delivered over SMTP. The defaults target the **Heroku SendGrid add-on**, which
provisions `SENDGRID_USERNAME` / `SENDGRID_PASSWORD` automatically — no extra
config is needed beyond:

- `APP_HOST` — the public hostname, so reset links point at the right place.
- `MAIL_FROM` — the sender address (use a domain verified in SendGrid).

To use a different provider (Mailgun, Postmark, plain SMTP, …) set the generic
overrides instead: `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USERNAME`,
`SMTP_PASSWORD`. See `config/environments/production.rb`.

In development, emails are not sent — Devise reset links are printed to the
Rails server log.

## Admin operations

After signing in as admin, visit `/admin`:
- **Group matches**: enter final scores for each of the 72 fixtures. Result (`home`/`draw`/`away`) is derived from scores and group picks are rescored automatically.
- **Knockout matches**: enter scores; winner advances and feeds the next round's bracket slot. Bracket picks rescore on save.
- **Teams**: rename play-off placeholders and reassign groups (useful when the Inter-Confed/UEFA play-off winners are decided).
- **Recompute scores**: re-runs the full scoring + slot-resolution pipeline.
