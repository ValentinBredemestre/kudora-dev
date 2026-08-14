# Kudora development workspace

This repository prepares a local Kudora workspace. It detects the GitHub user
authenticated with the GitHub CLI, then clones that user's required forks into
this directory.

## Requirements

- [Git](https://git-scm.com/downloads)
- [GitHub CLI](https://cli.github.com/) authenticated with `gh auth login`
- `make`
- Forks of [`kudora-app-backend`](https://github.com/Kudora-Labs/kudora-app-backend)
  and [`kudora-app-front`](https://github.com/Kudora-Labs/kudora-app-front)

On Windows, run the commands from Git Bash. Git for Windows includes Git Bash;
`make` can be installed with a package manager such as Chocolatey or Scoop.

## Setup

```sh
git clone https://github.com/YOUR_GITHUB_USER/kudora-dev.git
cd kudora-dev
make setup
```

The repositories are cloned inside `kudora-dev`:

```text
kudora-dev/
├── Makefile
├── scripts/
├── kudora-app-backend/
└── kudora-app-front/
```

Run `make sync` at any time to pull the latest changes. The update uses
`git pull --ff-only`, so it does not rewrite the repository's history.

Available commands:

```sh
make setup  # Clone repositories that are not installed yet
make sync   # Pull the latest changes in installed repositories
make zip    # Create out/kudora-dev.zip for sharing
make help   # Display the command list
```

`make zip` archives the current `kudora-app-backend/` and `kudora-app-front/`
working trees while respecting their `.gitignore` files. Git metadata, caches,
build output, local state, and temporary files are excluded.

Running `make` without a command returns an error instead of starting an
operation implicitly.

If the GitHub CLI is unavailable, the script uses the owner of the
`kudora-dev` origin. You can also select an account or destination explicitly:

```sh
GITHUB_USER=your-name WORKSPACE_ROOT=/path/to/workspace make setup
```

## Adding repositories

Add the repository name to the space-separated `REPOSITORIES` value in
`scripts/repositories.sh`, then add its directory to `.gitignore`.
