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

### User Stories

1. **Search for recipes from available products:**
As an improvising home cook, I want to enter the ingredients I have on hand so that the service suggests recipes that include all of them, helping me decide what to cook without extra shopping.

2. **Maintain personal ingredient “fridges”:**
As a registered user, I want to create and name multiple fridges where I store lists of ingredients, so that I can reuse them later to find recipes without re‑entering items every time.

3. **Rank recipe suggestions by fridge matches:**
As a fridge owner, I want recipes to be ranked by how many of my fridge items they contain, so that the best‑matching meals appear first and I can minimize wasted food.

### TODO

-[ ] Add specs;
-[ ] Add swagger;
-[ ] Custom error pages;
-[ ] Optimise logging;
