locals {
    regex_last_section_hyphen = "/.*-([A-Za-z]+).*/" # extracts the last section of a string after any hyphens (-) e.g. extracts `SBOX` from `DTS-RBAC-SBOX`
}