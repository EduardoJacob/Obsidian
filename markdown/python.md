---
title: Knowledge
output:
  pdf_document:
    latex_engine: xelatex
header-includes:
  - \usepackage{graphicx}
  - \graphicspath{{C:/MEGA/Obsidian/_attachments/}}
---

\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

A decorator in **Python** is a powerful, concise way to **modify or extend the behavior** of functions (or methods and classes) without changing their actual code. Think of it as adding a wrapper around the original callable that can do something before, after, or even replace the call.

Key purposes:

| Purpose | What it does | Typical use‑case |
|---------|--------------|------------------|
| **AOP‑style cross‑cutting concerns** | Adds behaviour that crosses function boundaries (e.g., logging, timing, authentication). | Automatically log every call to a view in a web app. |
| **Reusable wrappers** | Centralize functionality so it can be applied to many functions. | Caching results, memoization. |
| **Aspect replacement / enforcement** | Enforce pre‑conditions or modify outputs. | Validate arguments, ensure user has permissions. |
| **Readability & declarative intent** | Express intent in a clean syntactic form (`@decorator`). | `@profile` to benchmark; `@staticmethod` to declare method type. |

### How it works (in a nutshell)

```python
def my_decorator(func):
    def wrapper(*args, **kwargs):
        # code before calling the original function
        result = func(*args, **kwargs)
        # code after calling it
        return result    # or maybe transform `result`
    return wrapper

@my_decorator              # <-- this is how we use a decorator
def greet(name):
    print(f"Hello, {name}!")
```

The `@my_decorator` line is syntactic sugar for:

```python
greet = my_decorator(greet)
```

So when you call `greet("Alice")`, the interpreter actually runs the inner `wrapper` defined inside the decorator. This gives you a new callable that retains the signature of the original but has extra behaviour.

### Common built‑in decorators

- `@staticmethod` / `@classmethod`: change how methods are called on class objects.
- `@property`: turn a method into an attribute-like getter/setter.
- `functools.wraps`: preserve metadata (name, docstrings) when writing your own decorators.
- `functools.lru_cache`: simple memoization cache.

### Custom examples

1. **Timing a function**

```python
import time
from functools import wraps

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        t0 = time.perf_counter()
        result = func(*args, **kwargs)
        print(f"{func.__name__} took {time.perf_counter() - t0:.4f}s")
        return result
    return wrapper

@timer
def heavy_task():
    time.sleep(1)

heavy_task()
```

2. **Enforcing a user permission**

```python
def requires_role(role):
    def decorator(func):
        @wraps(func)
        def wrapper(user, *args, **kwargs):
            if role not in user.roles:
                raise PermissionError("Access denied")
            return func(user, *args, **kwargs)
        return wrapper
    return decorator

@requires_role('admin')
def delete_user(admin_user, target_id):
    # ...
```

---

**Bottom line:** Decorators let you write reusable, composable wrappers that make code *cleaner*, *more declarative*, and *less error‑prone*. They’re a first‑class language feature in Python for adding “extra” behaviour to functions in a way that’s both readable and flexible.





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

That line is called a **docstring** (documentation string).

Example:

```python
def get_weather(city):
    """Get the weather for a city"""
    ...
```

The triple quotes (`""" ... """`) create a string literal. When it appears as the **first statement inside a function, class, or module**, Python treats it specially as the object's documentation.

You can access it with the `__doc__` attribute:

```python
def get_weather(city):
    """Get the weather for a city"""
    pass

print(get_weather.__doc__)
```

Output:

```text
Get the weather for a city
```

Docstrings are used by:

* IDEs (VS Code, Positron, PyCharm, etc.) to show tooltips
* The `help()` function
* Documentation generators such as Sphinx
* Other developers reading your code

Example:

```python
def add(a, b):
    """
    Add two numbers and return the result.

    Parameters
    ----------
    a : float
        First number.
    b : float
        Second number.

    Returns
    -------
    float
        Sum of a and b.
    """
    return a + b
```

Then:

```python
help(add)
```

will display that documentation.

Note that triple quotes can also be used for ordinary multi-line strings:

```python
text = """
Line 1
Line 2
Line 3
"""
```

The difference is that when the string is the first statement in a function, class, or module, it becomes the object's docstring.





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

Python doesn’t have a single built-in equivalent to R’s `.Renviron`, but the **standard practice is very similar conceptually**: you store secrets in **environment variables**, usually loaded from a `.env` file or the system environment.

Here are the common (and correct) ways.

---

# 🥇 1. `.env` file (most common in Python)

This is the closest equivalent to `.Renviron`.

### Step 1 — create a `.env` file

In your project folder:

```text id="env1"
API_KEY=your_secret_key_here
OPENAI_API_KEY=abc123
DATABASE_PASSWORD=secret
```

---

### Step 2 — install dotenv support

```bash id="env2"
uv add python-dotenv
```

---

### Step 3 — load it in Python

```python id="env3"
from dotenv import load_dotenv
import os

load_dotenv()

api_key = os.getenv("API_KEY")
print(api_key)
```

---

## 🧠 Why this is popular

* Works across Windows / Linux / Mac
* Keeps secrets out of code
* Easy to use with uv / venv / Docker / CI pipelines
* Standard in ML + web development

---

# 🥈 2. System environment variables (most secure)

Instead of a file, you set variables in the OS.

### Windows (PowerShell)

```powershell id="env4"
setx API_KEY "your_secret_key"
```

Then in Python:

```python id="env5"
import os
print(os.getenv("API_KEY"))
```

---

## ✔ Pros

* More secure than files
* Used in production systems
* Works with servers and cloud platforms

## ❌ Cons

* Harder to manage locally
* Not project-specific

---

# 🥉 3. uv / venv project + environment variables

If you're using uv:

```powershell id="env6"
uv run python script.py
```

uv will automatically inherit environment variables from:

* system environment
* `.env` (if loaded via dotenv)

uv itself does **not manage secrets directly** — it relies on standard Python + OS mechanisms.

---

# 🟡 4. Secret managers (for production)

Used in real deployments:

* AWS Secrets Manager
* Azure Key Vault
* Google Secret Manager
* HashiCorp Vault

These are for:

* servers
* production apps
* CI/CD pipelines

Not for local dev.

---

# 🚫 What NOT to do

❌ Hardcoding secrets:

```python id="bad1"
API_KEY = "123456"   # never do this
```

❌ Committing `.env` to Git:

```text id="bad2"
.env  ❌ should be in .gitignore
```

---

# 🧠 Best practice (Python equivalent of `.Renviron`)

The closest equivalent is:

> `.env + python-dotenv + os.getenv()`

---

# 📁 Typical project structure

```text id="proj1"
myproject/
├── .env              ❌ not committed
├── .gitignore
├── pyproject.toml
├── .venv/
└── main.py
```

`.gitignore` should include:

```text id="proj2"
.env
```

---

# ⚡ Key idea

| R                 | Python               |
| ----------------- | -------------------- |
| `.Renviron`       | `.env` file + dotenv |
| `Sys.getenv()`    | `os.getenv()`        |
| RStudio auto-load | manual or dotenv     |

---

# 🟢 Summary

Python’s equivalent of `.Renviron` is:

> ✔ `.env` file + `python-dotenv` + `os.getenv()`

This is the standard, portable, and uv-compatible way to manage API tokens.

---

If you want, I can show you a **secure setup for API keys specifically for langchain / OpenAI / HuggingFace with uv**, since those tools each have slightly different conventions.





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

Yes — Hugging Face tokens are straightforward to use, but there are a few **important best practices and “gotchas”** that matter in real projects.

---

# 🔐 1. Treat the token like a password

Your Hugging Face access token gives access to:

* private models
* paid inference endpoints (if enabled)
* your account identity in API calls

So:

❌ Never hardcode it in Python
❌ Never commit it to Git
✔ Use environment variables

---

# 🥇 2. Recommended way (environment variable)

## Option A — `.env` file (local dev)

Install helper:

```bash
uv add python-dotenv
```

Create `.env`:

```text
HF_TOKEN=hf_your_token_here
```

Python:

```python
import os
from dotenv import load_dotenv

load_dotenv()

token = os.getenv("HF_TOKEN")
```

---

## Option B — system environment variable (best practice)

### PowerShell (Windows):

```powershell
setx HF_TOKEN "hf_your_token_here"
```

Then in Python:

```python
import os
token = os.getenv("HF_TOKEN")
```

---

# 🤗 3. Hugging Face library automatically supports this

If you're using:

### Transformers

[Hugging Face Transformers](https://huggingface.co/docs/transformers?utm_source=chatgpt.com)

You often don’t even need to manually pass the token:

```python
from transformers import pipeline

pipe = pipeline(
    "text-generation",
    model="meta-llama/Llama-3-8B",
    token=True  # or omit entirely if env var is set
)
```

It automatically reads:

```text
HF_TOKEN
```

or older name:

```text
HUGGINGFACE_HUB_TOKEN
```

---

# 🧠 4. Hugging Face Hub CLI login (optional but useful)

You can also authenticate once:

```bash
huggingface-cli login
```

This stores your token locally in:

```text
C:\Users\<you>\.huggingface\token
```

After that:

* Python libraries auto-detect it
* No need for env variables in simple setups

---

# ⚠️ 5. Common mistakes

## ❌ Wrong variable name

People often use:

```text
API_KEY
```

But Hugging Face expects:

```text
HF_TOKEN
or
HUGGINGFACE_HUB_TOKEN
```

---

## ❌ Committing `.env`

Always ensure:

```text
.env
```

is in `.gitignore`

---

## ❌ Using token in shared notebooks

If using Jupyter / RStudio / VS Code notebooks:

* don’t print the token
* don’t embed it in outputs

---

# 🔒 6. Scope your token properly (important)

When creating your token at:
[Hugging Face Settings Tokens](https://huggingface.co/settings/tokens?utm_source=chatgpt.com)

Prefer:

* **Read-only** (recommended for most ML use cases)
* Avoid “write” unless you upload models/datasets

---

# ⚡ 7. uv-specific note (your setup)

Since you're using uv:

```bash
uv run python script.py
```

👉 uv automatically inherits:

* system environment variables
* `.env` (if you load it)

So nothing special is needed — uv does not interfere with secrets.

---

# 🧪 8. Quick sanity check

```python
import os
print(os.getenv("HF_TOKEN")[:5])
```

You should see something like:

```text
hf_Abc
```

(not the full token)

---

# 🟢 Best practice summary

For your setup (uv + Python + ML):

✔ Store token in `.env` or system env
✔ Use `HF_TOKEN`
✔ Load via `os.getenv()`
✔ Keep token out of Git
✔ Prefer read-only tokens

---

# 💡 Mental model

Think of Hugging Face auth as:

> “Just another environment variable consumed by libraries automatically”

---

If you want, I can show you how to use the token with:

* `transformers`
* `huggingface_hub`
* or langchain / LangGraph

since each has slightly different patterns.





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

**LangChain** is a Python (and JavaScript) framework for building applications powered by **large language models (LLMs)** like GPT, LLaMA, Claude, etc.

It helps you go beyond simple “prompt → response” and build **real AI applications**.

---

# 🧠 Simple definition

> LangChain is a toolkit for connecting LLMs to data, tools, and workflows.

Instead of just asking:

```text
"Summarize this text"
```

you can build systems like:

* Chatbots that remember conversations
* AI agent that use tools (web search, Python, databases)
* RAG systems (chat with your documents)
* Multi-step reasoning pipelines

---

# 🧱 What LangChain actually gives you

## 1. LLM wrappers

A standard interface to use different models:

* OpenAI
* Anthropic
* Hugging Face
* local models (Ollama, etc.)

---

## 2. Prompt templates

Instead of hardcoding prompts:

```python
"You are a helpful assistant. Summarize: {text}"
```

you use templates:

```python
from langchain.prompts import PromptTemplate
```

---

## 3. Chains (core idea)

A **chain** = multiple steps connected together.

Example:

```
input → prompt → LLM → post-processing → output
```

---

## 4. Agents (very important)

Agents can:

* decide what to do
* call tools
* loop reasoning steps

Example tools:

* calculator
* Python REPL
* web search
* database query

So instead of just answering, the model can *act*.

---

## 5. Memory

Lets a chatbot remember context:

* previous messages
* user preferences
* session history

---

## 6. RAG (Retrieval-Augmented Generation)

This is one of the most important uses.

Flow:

```
User question
   ↓
Search documents / vector DB
   ↓
Relevant context
   ↓
LLM generates answer
```

This is how you build:

* “chat with your PDFs”
* company knowledge assistants
* document Q&A systems

---

# 🔧 Minimal example

```python
from langchain.chat_models import ChatOpenAI

llm = ChatOpenAI()

response = llm.invoke("Explain quantum computing simply")
print(response)
```

---

# 🧠 Why LangChain exists

Without it, you would manually write:

* API calls to LLMs
* prompt handling
* memory logic
* tool routing
* retrieval systems
* chaining logic

LangChain tries to unify all of that.

---

# ⚖️ Important honest note (2026 reality)

LangChain is:

### 👍 Pros

* Very powerful
* Huge ecosystem
* Fast prototyping for LLM apps

### 👎 Cons

* Can feel complex / over-engineered
* APIs change often
* Some developers now prefer lighter frameworks (e.g. LlamaIndex, raw OpenAI SDK)

---

# 🧠 Mental model

Think of LangChain as:

> “Glue between LLMs and everything else (data, tools, memory, workflows)”

---

If you want, I can show you:

* a **real LangChain chatbot with memory**
* or a **RAG system (chat with PDFs)**
* or how it compares to **LlamaIndex and plain OpenAI API**

Just tell me 👍





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

Version: 1.10.x

# What is Langflow?

Langflow is an open-source, Python-based, customizable framework for building AI applications. It supports important AI functionality like agent and the Model Context Protocol (mcp), and it doesn't require you to use specific large language models (LLMs) or vector stores.

The visual editor simplifies prototyping of application workflows, enabling developers to quickly turn their ideas into powerful, real-world solutions.

Try it

Build and run your first flow in minutes: Install Langflow, and then try the Quickstart.

#### Quickstart

Build and run your first flow in minutes.#### Components

Explore all available components and integrations.#### Deploy

Deploy Langflow to production environments.

## Application development and prototyping​





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

**Pydantic** is a Python library used to **validate, parse, and manage structured data**.

It lets you define data models using normal Python classes and type hints, and then automatically checks that incoming data matches the expected types.

Example:

```python
from pydantic import BaseModel

class Person(BaseModel):
    name: str
    age: int
```

Now you can create instances:

```python
person = Person(
    name="Eduardo",
    age=42
)

print(person.name)
print(person.age)
```

Output:

```text
Eduardo
42
```

---

## Validation

If the data is wrong:

```python
person = Person(
    name="Eduardo",
    age="forty-two"
)
```

Pydantic raises a detailed error:

```text
ValidationError:
age
  Input should be a valid integer
```

---

## Automatic Conversion

Pydantic often converts compatible values automatically:

```python
person = Person(
    name="Eduardo",
    age="42"
)

print(type(person.age))
```

Output:

```text
<class 'int'>
```

The string `"42"` was converted to the integer `42`.

---

## Why is it useful?

Suppose you receive JSON from:

* an API
* a database
* a configuration file
* an LLM

Without Pydantic:

```python
data = response.json()

name = data["name"]
age = int(data["age"])
```

You manually check everything.

With Pydantic:

```python
person = Person.model_validate(data)
```

Pydantic does the checking and conversion for you.

---

## Pydantic and LLMs

Pydantic is heavily used with langchain, OpenAI, Anthropic, and agent frameworks.

Example:

```python
from pydantic import BaseModel

class Weather(BaseModel):
    city: str
    temperature: float
```

You can tell an LLM:

> "Return the answer in the format of the Weather schema."

Then parse the response directly into a Python object.

---

## tools Definitions

When creating tools for agents:

```python
from pydantic import BaseModel

class ReadFileInput(BaseModel):
    filename: str
```

```python
@tool
def read_file(filename: str):
    ...
```

or

```python
@tool(args_schema=ReadFileInput)
def read_file(filename: str):
    ...
```

Pydantic validates the tool arguments before the tool runs.

---

## Common BaseModel Methods

### Convert to dictionary

```python
person.model_dump()
```

Output:

```python
{
    "name": "Eduardo",
    "age": 42
}
```

---

### Convert to JSON

```python
person.model_dump_json()
```

Output:

```json
{"name":"Eduardo","age":42}
```

---

### Validate external data

```python
Person.model_validate(data)
```

---

## Why LangChain developers use it so much

Because agents constantly exchange structured data:

```text
User
  ↓
LLM
  ↓
Tool Call
  ↓
Tool Output
  ↓
LLM
```

Pydantic guarantees that data moving between these components has the expected structure.

Without it, you'd write lots of manual checks like:

```python
if "filename" not in data:
    ...
if not isinstance(data["filename"], str):
    ...
```

Pydantic automates all of that.

### In one sentence

**Pydantic is a library that turns Python type hints into runtime data validation and parsing, making it much easier to work with structured data, APIs, and LLM tool inputs/outputs.**





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

Index created by obsidian.R at 2026-11-21 18:47:01.836471
[[decorator]]
Python decorators are powerful, reusable wrappers that modify or extend function behavior without altering their core code. Applied cleanly using the `@` syntax, they are ideal for cross-cutting concerns like logging, authentication, caching, and timing.
 
[[docstrings]]
A docstring is a triple-quoted string placed at the beginning of a Python function, class, or module to serve as documentation. It is accessible via the `__doc__` attribute and used by IDEs, the `help()` function, and developers.
 
[[dotenv]]
Python manages secrets similarly to R’s `.Renviron` by using a `.env` file combined with the `python-dotenv` package and `os.getenv()`. This standard, secure practice keeps sensitive data out of your source code and works seamlessly across environments.
 
[[hf token]]
Treat Hugging Face tokens like passwords by using environment variables (`HF_TOKEN`) instead of hardcoding them. Always add `.env` files to `.gitignore`, prefer read-only token scopes, and let Hugging Face libraries detect credentials automatically.
 
[[langchain]]
LangChain is a Python and JavaScript framework that connects large language models to data, tools, and workflows. It simplifies building advanced AI applications like chatbots, agents, RAG systems, and multi-step reasoning pipelines by providing unified wrappers and components.
 
[[langflow]]
Langflow is an open-source, Python-based visual framework for building and prototyping customizable AI applications. It supports agents and the Model Context Protocol without restricting your choice of LLMs or vector stores, enabling fast workflow development.
 
[[pydantic]]
Pydantic is a Python library that uses type hints to validate, parse, and manage structured data. It automates type checking and conversions, making it essential for safely handling data from APIs, configurations, and LLM agent workflows.
 
[[toml]]
TOML is a human-readable configuration file format used in modern Python projects. Specifically, the `pyproject.toml` file serves as the standard location for storing project metadata, dependencies, and tool settings for utilities like uv, ruff, and pytest.
 
[[triple quotes]]
In Python, triple quotes are versatile string literals used to write multi-line strings, create docstrings for documentation, format long text blocks, and preserve exact spacing. Note that they are functional strings, not actual code comments.
 
[[uv lock]]
The `uv lock` command resolves and freezes exact dependency versions from your `pyproject.toml` into a `uv.lock` file, ensuring a stable, reproducible environment across machines and enabling faster, reliable installations with `uv sync`.
 
[[uv]]
This note highlights `uv` by Astral as an all-in-one Python tool for fast package management, virtual environments, and Python version control, complemented by Ruff for linting and formatting and pytest for testing.
 
\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

The **`.toml`** file extension stands for:

> **TOML = Tom’s Obvious, Minimal Language**

It is a **configuration file format**, designed to be easy for humans to read and write.

---

## Where you see `.toml` in Python

The most important one is:

```text
pyproject.toml
```

This is now the **standard configuration file for modern Python projects** (used by uv, pip, poetry, ruff, etc.).

---

## What TOML looks like

A `.toml` file is structured using simple key–value pairs:

```toml
name = "myproject"
version = "0.1.0"
```

---

## Tables (like sections)

TOML uses “tables” (similar to sections in INI files):

```toml
[project]
name = "demo"
version = "0.1.0"
```

---

## Nested tables

You can go deeper:

```toml
[tool.ruff]
line-length = 88

[tool.pytest.ini_options]
testpaths = ["tests"]
```

---

## Lists

```toml
dependencies = [
  "numpy",
  "pandas"
]
```

---

## Why Python uses TOML now

Python adopted TOML because:

* Easier to read than JSON
* More structured than `.ini`
* No confusing syntax like YAML indentation issues
* Good for configuration + metadata

---

## In your uv project

If you ran:

```powershell
uv init .
```

you likely got a file like:

```toml
[project]
name = "demo"
version = "0.1.0"
dependencies = []
```

This tells uv:

* project name
* dependencies
* Python requirements
* build settings

---

## TOML vs other formats

| Format | Example use     | Pros                 | Cons                    |
| ------ | --------------- | -------------------- | ----------------------- |
| TOML   | Python projects | readable, structured | less flexible than YAML |
| JSON   | APIs            | universal            | noisy, no comments      |
| YAML   | DevOps configs  | flexible             | indentation errors      |
| INI    | old configs     | simple               | very limited            |

---

## Key idea

> `.toml` is just a **human-readable configuration file format**, and `pyproject.toml` is where modern Python tools store project settings.

---

If you want, I can break down your actual `pyproject.toml` line-by-line so you fully understand what uv + ruff + pytest are doing in your project.





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

In Python, putting a string inside **triple quotes** (`""" ... """` or `''' ... '''`) serves a few important purposes.

---

## 1. Multi-line strings

This is the most common use.

With normal quotes:

```python id="a1"
text = "Line 1\nLine 2\nLine 3"
```

With triple quotes:

```python id="a2"
text = """Line 1
Line 2
Line 3"""
```

No need for `\n` — you can write it naturally across lines.

---

## 2. Docstrings (very important)

Triple quotes are used to document functions, classes, and modules.

Example:

```python id="a3"
def add(a, b):
    """Return the sum of a and b."""
    return a + b
```

This string becomes the function’s **documentation**:

```python id="a4"
print(add.__doc__)
```

Output:

```text id="a5"
Return the sum of a and b.
```

docstrings are used by:

* `help()`
* IDE tooltips
* documentation generators

---

## 3. Long text blocks (clean formatting)

Useful for SQL, JSON, prompts, etc.

Example:

```python id="a6"
prompt = """
You are a helpful assistant.
Answer clearly and concisely.
Avoid unnecessary detail.
"""
```

Much cleaner than concatenating strings.

---

## 4. Preserving formatting exactly

Triple quotes preserve:

* line breaks
* indentation (including spaces)

Example:

```python id="a7"
ascii_art = """
  /\_
 / o o \
(   V   )
"""
```

---

## 5. Important detail: it's still just a string

Triple quotes are not a special type — just syntax.

These are equivalent:

```python id="a8"
"hello"
"""hello"""
'''hello'''
```

---

## 6. Common confusion

### ❌ Not comments

People sometimes think this is a comment:

```python id="a9"
"""
This looks like a comment
"""
```

But it's actually a **string literal**. If it's not assigned or used, Python just ignores it at runtime, but it still exists briefly in the code execution flow.

Real comments use:

```python id="a10"
# This is a comment
```

---

## Summary

Triple quotes are mainly used for:

* Multi-line strings
* Docstrings (documentation)
* Readable large text blocks
* Preserving formatting

They make code cleaner when dealing with long or structured text.





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

`uv lock` is the command that **creates or updates a lock file (`uv.lock`) for your project**.


Think of it as:

> “Freeze the exact versions of all dependencies so your environment is reproducible.”

---

## 🧠 What problem does it solve?

When you write in `pyproject.toml`:

```toml
dependencies = [
  "requests",
  "numpy"
]
```

Those are **loose requirements**:

* `requests` could become 2.31 today, 2.32 tomorrow
* `numpy` could change minor versions

That can break your code unexpectedly.

---

## 🔒 What `uv lock` does

When you run:

```powershell
uv lock
```

uv:

1. Reads `pyproject.toml`
2. Resolves all dependencies (including sub-dependencies)
3. Chooses exact compatible versions
4. Writes them into:

```text
uv.lock
```

---

## 📄 Example

### Before (pyproject.toml)

```toml
dependencies = [
  "requests"
]
```

---

### After `uv lock`

`uv.lock` contains something like:

```text
requests==2.32.3
urllib3==2.2.1
certifi==2024.2.2
charset-normalizer==3.3.2
```

So everything is **fully pinned**.

---

## 🚀 Why this matters

### ✔ Reproducibility

Everyone gets the exact same environment:

```bash
uv sync
```

will install **exact versions from uv.lock**.

---

### ✔ Stability

Prevents:

* “works on my machine” problems
* unexpected breaking updates

---

### ✔ Fast installs

uv uses the lock file to skip dependency solving.

---

## 🔁 Relationship with other commands

| Command   | What it does                        |
| --------- | ----------------------------------- |
| `uv add`  | add a dependency                    |
| `uv lock` | resolve + freeze versions           |
| `uv sync` | install exactly what's in lock file |
| `uv run`  | execute inside environment          |

---

## ⚙️ Typical workflow

```powershell
uv init .
uv add requests numpy
uv lock
uv sync
```

Then later:

```powershell
uv run python script.py
```

---

## 🔥 Key idea

> `uv lock` creates a **precise snapshot of your dependency tree**, ensuring your project is reproducible everywhere.

---

## 🆚 Comparison with pip tools

| Tool      | Lock file        |
| --------- | ---------------- |
| pip       | ❌ none           |
| pip-tools | requirements.txt |
| poetry    | poetry.lock      |
| uv        | uv.lock          |

---

## One-line summary

👉 `uv lock` = “figure out exact package versions and freeze them into uv.lock”

---

If you want, I can explain the difference between **`uv lock` vs `uv sync` vs `uv add`**, because those three often confuse people at first.





\newpage
---
tags:
  - python
---

![[python.png]]

<!-- END -->

https://github.com/astral-sh/uv
https://docs.astral.sh/uv/getting-started/features/
uv for package and environment management
Ruff for linting and formatting
pytest for testing

uv self update

uv python list
uv python install
uv python install 3.11
uv python find
uv python uninstall

uv run example.py
uv run python main.py
uv run python --version

uv init .
uv add --dev ruff
uv add --dev pytest
uv run ruff check .
uv run pytest

uv lock
uv sync








