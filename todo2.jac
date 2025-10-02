# todo2.jac
# Automated To-Do List Generator using the Gemini API key.

# 1. Import the Model object.
import from byllm { Model }

# 2. Configure the LLM model to use GEMINI (and fix the API endpoint).
# The 'gemini/' prefix forces litellm to use the GEMINI_API_KEY environment variable
# and connect to the correct Google AI Studio API endpoint automatically.
glob llm = Model(
    model_name="gemini/gemini-2.0-flash" 
    # The incorrect api_base="https://api.gemini.ai" has been removed.
);

# 3. Define the desired structured output.
obj Task {
    has description: str;
    has priority: str; # Must be 'High', 'Medium', or 'Low'
}

# 4. Define the function to be automated.
"""
Generate a list of 5 prioritized tasks required to complete the given project.
Priorities must be strictly one of 'High', 'Medium', or 'Low'.
"""
def generate_tasks(project_idea: str) -> list[Task] by llm();

# 5. Execute the application logic.
with entry {
    project = "Build a simple web application for tracking personal finances with a database.";
    
    print(f"**Asking Gemini to generate tasks for: {project}**\n");
    
    # Call the LLM-powered function
    generated_tasks: list[Task] = generate_tasks(project);
    
    print("--- AI-Generated To-Do List (via Gemini) ---");
    
    # Iterate and print the structured tasks
    for task in generated_tasks {
        print(f"[{task.priority}] {task.description}");
    }
}