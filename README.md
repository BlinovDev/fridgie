# Fridgie

Fridgie is a simple service for finding recipes based on the ingredients you already have at home.
Just enter products (e.g., bread, chicken) and the app will return recipes that include all of them.

The main goal is to help reduce food waste by making better use of what you already bought.
Future plans include user accounts (via Devise) and personal “fridges” where users can store their ingredients and receive tailored recipe suggestions.

### Run locally

App supports run through the Docker Compose.
```bash
docker compose build
docker compose up
```
This will make the app run, but with no data.

### Deploy
```bash
# following command will deploy to Prod actual version of main branch
bundle exec cap production deploy
```
