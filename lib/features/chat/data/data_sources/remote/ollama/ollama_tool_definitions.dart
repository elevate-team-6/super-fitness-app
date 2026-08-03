const Map<String, dynamic> searchExercisesTool = {
  "type": "function",
  "function": {
    "name": "search_exercises",
    "description":
        "Find exercises in the app's catalog. Use the exact vocabulary values listed in the system prompt. Call this before recommending any exercise.",
    "parameters": {
      "type": "object",
      "properties": {
        "muscle_group": {"type": "string"},
        "equipment": {"type": "string"},
        "max_difficulty": {
          "type": "integer",
          "minimum": 1,
          "maximum": 8,
          "description":
              "1=Beginner .. 8=Legendary. Returns everything at or below this level.",
        },
        "movement_pattern": {"type": "string"},
        "body_region": {
          "type": "string",
          "enum": ["Upper Body", "Lower Body", "Midsection", "Full Body"],
        },
        "mechanics": {
          "type": "string",
          "enum": ["Compound", "Isolation"],
        },
        "exclude_equipment": {"type": "string"},
        "limit": {"type": "integer", "default": 6, "maximum": 8},
      },
      "required": [],
    },
  },
};

const Map<String, dynamic> searchMealsTool = {
  "type": "function",
  "function": {
    "name": "search_meals",
    "description":
        "Find meals in the app's catalog. Call this before recommending any meal.",
    "parameters": {
      "type": "object",
      "properties": {
        "category": {"type": "string"},
        "area": {"type": "string"},
        "min_protein": {"type": "number"},
        "max_kcal": {"type": "number"},
        "vegetarian": {"type": "boolean"},
        "vegan": {"type": "boolean"},
        "gluten_free": {"type": "boolean"},
        "exclude_ingredient": {"type": "string"},
        "limit": {"type": "integer", "default": 6, "maximum": 8},
      },
      "required": [],
    },
  },
};

const Map<String, dynamic> searchByTextTool = {
  "type": "function",
  "function": {
    "name": "search_by_text",
    "description":
        "Full-text search over exercises and/or meals when the user's phrasing doesn't map cleanly to the structured vocabulary. Use as a fallback when search_exercises/search_meals return nothing useful.",
    "parameters": {
      "type": "object",
      "properties": {
        "query": {"type": "string"},
        "domain": {
          "type": "string",
          "enum": ["exercise", "meal", "both"],
        },
      },
      "required": ["query"],
    },
  },
};
