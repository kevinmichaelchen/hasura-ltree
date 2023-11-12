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

### Creating a root node

```graphql
mutation CreateRoot {
  insertOrgUnitOne(
    object: {
      name: "ROOT"
    }
  ) {
    id
    path
    codePath
  }
}
```

### Creating a child

It's important to pay attention to the `parentId` here:

```graphql
mutation CreateChild {
  insertOrgUnitHierarchyOne(
    object: {
      parentId: "c46666ab-6426-4196-a093-e45e09f207e6"
      child: {
        data: {
          name: "CHILD"
        }
      }
    }
  ) {
    child {
      path
      codePath
    }
  }
}
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

## Using `psql`

We can perform an insert:

```shell
PGPASSWORD=postgrespassword pkgx psql \
  -h localhost \
  -p 15432 \
  -U postgres \
  -d postgres \
  --command="truncate org_unit_hierarchy; delete from org_unit where name != 'ROOT'; begin; insert into org_unit (name) values ('CHILD'); insert into org_unit_hierarchy (parent_id, child_id) select (select id from org_unit where name = 'ROOT'), (select id from org_unit where name = 'CHILD'); commit;"
```

## Under the hood

https://medium.com/swlh/postgres-recursive-query-cte-or-recursive-function-3ea1ea22c57c
