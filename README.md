# hasura-ltree

Exploring LTREEs with Hasura.

LTREEs are perfect for any kind of hierarchical data model.

- [Blog — Query hierarchical data structures on Hasura with Postgres ltree][blog-query]
- [Blog — GraphQL and Tree Data Structures with Postgres on Hasura GraphQL engine][blog-tree]
- [Docs — Postgres: Filter by Hierarchical ltree Data][docs-ltree]
- [Video — Early look at Hasura support for ltree Postgres operators][video-ltree]

[blog-query]: https://hasura.io/blog/query-hierarchical-data-structures-on-hasura-with-postgres-ltree/
[blog-tree]: https://hasura.io/blog/graphql-and-tree-data-structures-with-postgres-on-hasura-dfa13c0d9b5f/
[docs-ltree]: https://hasura.io/docs/latest/queries/postgres/filters/ltree-operators/
[video-ltree]: https://www.youtube.com/watch?v=_hPbpDUniFQ

## Getting started

### Starting Hasura

Just run:

```shell
make
```

### Prerequisites

This package is powered by [pkgx][pkgx], which you can install with:

```shell
curl -fsS https://pkgx.sh | sh
```

> [!NOTE]
> You can easily uninstall pkgx with `sudo rm $(which pkgx)` and `sudo rm -rf ~/.pkgx`

[pkgx]: https://pkgx.sh/

## Using the API

### Create nodes

```graphql
mutation CreateNodes {
  insertOrgUnit(
    objects: [
      {name: "L1"},
      {name: "L2"},
      {name: "L3"}
    ]
  ) {
    returning {
      name
      id
      path
      codePath
    }
  }
}
```

### Creating hierarchy

We can perform an insert:

```shell
PGPASSWORD=postgrespassword pkgx psql \
  -h localhost \
  -p 15432 \
  -U postgres \
  -d postgres \
  --command="truncate org_unit_hierarchy; begin; insert into org_unit_hierarchy (parent_id, child_id) select (select id from org_unit where name = 'L1'), (select id from org_unit where name = 'L2'); insert into org_unit_hierarchy (parent_id, child_id) select (select id from org_unit where name = 'L2'), (select id from org_unit where name = 'L3'); commit;"
```

### Listing everything

```graphql
query ListOrgUnits {
  orgUnit {
    name
    id
    path
    code
    codePath
  }
  orgUnitHierarchy {
    parentId
    childId
  }
}
```

### Querying for ancestors (and self)

```graphql
query {
  test(where: { path: { _ancestor: "AAA.BBB.CCC" } }) {
    path
  }
}
```

## Are hyphens allowed?

UUIDs contain hyphens. Are hyphens allowed in LTREEs?

[Historically, no][hyphen-support].

However, that will change in Postgres 16 with this [patch][hyphen-patch].

As of this writing, PG 16 is [not supported][rds-postgres-release-cal] in AWS RDS.

[hyphen-support]: https://stackoverflow.com/questions/29887093/valid-characters-in-postgres-ltree-label-in-utf8-charset
[hyphen-patch]: https://github.com/postgres/postgres/commit/b1665bf01e5f4200d37addfc2ddc406ff7df14a5
[rds-postgres-release-cal]: https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-release-calendar.html#Release.Calendar

## Under the hood

https://medium.com/swlh/postgres-recursive-query-cte-or-recursive-function-3ea1ea22c57c
