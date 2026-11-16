# Upgrade from v12.x to v12.x

## List of backwards incompatible changes

- Change variable types (if you were using defaults, there is no breaking change, but you might get terraform state drift):
    - `deployment.pdb_max_unavailable` number -> string
    - `deployment.pdb_min_available` number -> string

