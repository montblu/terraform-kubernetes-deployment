# Upgrade from v10.x to v11.x

## List of backwards incompatible changes

- The minimum required `kubernetes` provider version is now `3.2` (`>= 3.2`); provider v3 removed the unversioned resource aliases used previously
- `kubernetes_deployment` resource has been renamed to `kubernetes_deployment_v1`
- `kubernetes_service` resource has been renamed to `kubernetes_service_v1`

## Additional changes

### Modified

- None. Resource schemas for `kubernetes_deployment_v1` / `kubernetes_service_v1` are unchanged from `kubernetes_deployment` / `kubernetes_service`; only the resource type name changed.

### Variable and output changes

1. Removed variables:

    - None

2. Renamed variables:

    - None

3. Added variables:

    - None

4. Removed outputs:

    - None

5. Renamed outputs:

    - None

6. Added outputs:

    - None

### State Changes

Terraform treats a resource type rename as delete-then-create, so existing state entries for `kubernetes_deployment.main` and `kubernetes_service.main` must be moved to their new addresses before running `terraform plan`/`apply`, otherwise Terraform will try to destroy and recreate the deployment and service.

Move the existing state entries to the new resource addresses:

```sh
terraform state mv kubernetes_deployment.main kubernetes_deployment_v1.main
terraform state mv kubernetes_service.main kubernetes_service_v1.main
```

If your module usage uses `count`/`for_each` (e.g. `main[0]`), include the index/key in both the source and destination addresses:

```sh
terraform state mv 'kubernetes_deployment.main[0]' 'kubernetes_deployment_v1.main[0]'
terraform state mv 'kubernetes_service.main[0]' 'kubernetes_service_v1.main[0]'
```

After moving state, run `terraform plan` and confirm it reports no changes (or only the expected changes unrelated to this upgrade).
