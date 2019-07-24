# You must run console as Administrator

function New-SymbolicLink ($target, $link) {
  New-Item -Path $link -ItemType SymbolicLink -Value $target
}

# New-SymbolicLink "Library" "..\..\Library"