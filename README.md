# Kudora development workspace

This repository prepares a local Kudora workspace. It detects the GitHub user
authenticated with the GitHub CLI, then clones that user's required forks. If a
repository is already present, it updates it with a fast-forward pull.

## Requirements

- [Git](https://git-scm.com/downloads)
- [GitHub CLI](https://cli.github.com/) authenticated with `gh auth login`
- `make`
- A fork of [`Kudora-Labs/kudora`](https://github.com/Kudora-Labs/kudora)

On Windows, run the commands from Git Bash. Git for Windows includes Git Bash;
`make` can be installed with a package manager such as Chocolatey or Scoop.

## Setup

```sh
git clone https://github.com/YOUR_GITHUB_USER/kudora-dev.git
cd kudora-dev
make
```

The repositories are cloned next to `kudora-dev`:

```text
workspace/
├── kudora-dev/
└── kudora/
```

Run `make` again at any time to pull the latest changes. The update uses
`git pull --ff-only`, so it never overwrites local work.

If the GitHub CLI is unavailable, the script uses the owner of the
`kudora-dev` origin. You can also select an account or destination explicitly:

```sh
GITHUB_USER=your-name WORKSPACE_ROOT=/path/to/workspace make
```

## Adding repositories

Add the repository name to the space-separated `REPOSITORIES` value in
`scripts/sync-repositories.sh`.
