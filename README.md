# biblioprobe

A docker-wrapped CLI tool around [bibliothecary](https://github.com/ecosyste-ms/bibliothecary) that
analyzes a code repository's package information and normalizes certain relevant information,
documented below. The repository may be complete or contain only package manager files like
package.json and package-lock.json or pnpm-lock.yaml.

## Example Usage

```bash
docker run -v <repo dir>:/data biblioprobe
```

This command probes the given repo directory and creates a file `biblioprobe.json` containing the following data:

```json
{
  "manifests": [
    {
      "ecosystem": "npm",
      "path": "package.json",
      "dependencies": [
        {
          "name": "semver",
          "requirement": "^7.7.3",
          "type": "runtime",
          "local": false
        },
        {
          "name": "chalk",
          "requirement": "^5.6.2",
          "type": "runtime",
          "local": false
        }
      ],
      "kind": "manifest",
      "success": true,
      "related_paths": [
        "package-lock.json"
      ]
    }
  ]
}
```
