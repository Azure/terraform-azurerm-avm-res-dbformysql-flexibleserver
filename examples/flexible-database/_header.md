# Flexible database example

This deploys a MySQL Flexible Server with a database.

The database uses the canonical `utf8mb3` character set and `utf8mb3_unicode_ci`
collation returned by Azure. These preserve the three-byte UTF-8 behavior of the
legacy `utf8` aliases without causing a replacement on the next Terraform plan.
