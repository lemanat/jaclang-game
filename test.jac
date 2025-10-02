import from byllm { Model }

glob llm = Model(
    model_name = "gemini/gemini-2.0-flash"
);

def greet(name: str) -> str by llm();

with entry {
    let out = greet("Lemi");
    print(out);
}
