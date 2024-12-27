const config = {
    branches: ['main'],
    plugins: [
        '@semantic-release/commit-analyzer',
        '@semantic-release/release-notes-generator',
        [
            "semantic-release-replace-plugin", 
            {
                "replacements": [
                    {
                        "files": ["addons/netpunk.gametools/plugin.cfg"],
                        "from": "version=\".*\"",
                        "to": "version=\"${nextRelease.version}\"",
                    "results": 
                    [
                        {
                            "file": "addons/netpunk.gametools/plugin.cfg",
                            "hasChanged": true,
                            "numMatches": 1,
                            "numReplacements": 1,
                        }
                    ],
                    "countMatches": true,
                    }
                ]
            }
        ],
        [
            "@semantic-release/git",
            {
                "assets": ["addons/netpunk.gametools/plugin.cfg"],
                "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
            }
        ],
        '@semantic-release/github'
    ],
};

module.exports = config;