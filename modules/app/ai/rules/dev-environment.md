# Development Environment & Tooling

## Environment Setup

- Each project should have a self-contained dev environment — avoid globally installed dependencies
- Use nix, devenv, and direnv to define the dev environment completely
- Nix should delegate package management to the project's native tooling (e.g. install uv for Python, node for JS, etc.)
- Projects should run without nix — nix defines the environment, not the runtime
- Bootstrap scripts or critical setup steps that are required to initialize the project may live outside of nix

## Scripting

- Default to bash for scripting unless the task is sufficiently complex or a more purpose-built tool exists
- When bash isn't enough, prefer a tool appropriate to the domain of the problem

## Frontend

- Prefer Angular over React — don't suggest switching if already in React
- Use Tailwind for styling

## Backend

- Avoid Python and Java for new projects
- Never suggest JVM-based languages or frameworks

## Testing

- Test all logic — business rules, data transformations, edge cases, and anything with a clear input/output contract
- Don't test the tools — third-party libraries, framework internals, simple API wrappers, and ORM calls with no logic
- UI rendering only needs tests if it contains embedded logic
