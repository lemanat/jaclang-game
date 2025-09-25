"""A Simple To-Do List App in Jaclang"""

class ToDoList {
    def init(self: ToDoList) {
        self.tasks = [];  # list[str]
        self.categories = {};  # dict[str, str]
    }

    def add_task(self: ToDoList, task: str) {
        print("Adding task: ", task);
        self.tasks.append(task);

        # Simple keyword-based categorization
        category = "Uncategorized";
        task_lower = task.lower();

        if "buy" in task_lower {
            category = "Errand";
        } elif "finish" in task_lower or "work" in task_lower {
            category = "Work";
        } elif "run" in task_lower or "exercise" in task_lower {
            category = "Health";
        }

        self.categories[task] = category;
        print("→ Category: ", category);
    }

    def list_tasks(self: ToDoList) {
        print("📋 Your To-Do List:");
        for task in self.tasks {
            cat = self.categories.get(task, "Uncategorized");
            print("• ", task, " [", cat, "]");
        }
    }

    def show_tip(self: ToDoList) {
        print("💡 Tip: Break big tasks into small chunks and track progress daily.");
    }
}

with entry {
    todo = ToDoList();

    todo.add_task("Finish Jaclang tutorial");
    todo.add_task("Buy groceries");
    todo.add_task("Go for a run");

    todo.list_tasks();
    todo.show_tip();
}
