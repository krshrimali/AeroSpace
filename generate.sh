#!/usr/bin/env bash
cd "$(dirname "$0")"
source ./script/setup.sh

version=$(head -1 ./version.txt | awk '{print $1}')
build_number=$(tail -1 ./version.txt | awk '{print $1}')

cat > LocalPackage/Sources/Common/versionGenerated.swift <<EOF
// FILE IS GENERATED BY generate.sh
public let aeroSpaceAppVersion = "$version"
EOF

sed -i "s/CURRENT_PROJECT_VERSION.*/CURRENT_PROJECT_VERSION: $build_number # GENERATED BY generate.sh/" ./project.yml
sed -i "s/MARKETING_VERSION.*/MARKETING_VERSION: $version # GENERATED BY generate.sh/" ./project.yml

entries() {
    for file in $(ls docs/aerospace-*.adoc); do
        if grep -q 'exec' <<< $file; then
            continue
        fi
        subcommand=$(basename $file | sed 's/^aerospace-//' | sed 's/\.adoc$//')
        desc="$(grep :manpurpose: $file | sed -E 's/:manpurpose: //')"
        echo "    [\"  $subcommand\", \"$desc\"],"
    done
}

cat <<EOF > ./LocalPackage/Sources/Cli/subcommandDescriptionsGenerated.swift
// FILE IS GENERATED BY generate.sh
let subcommandDescriptions = [
$(entries)
]
EOF

xcodegen # https://github.com/yonaskolb/XcodeGen
