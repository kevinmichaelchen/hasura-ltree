# hasura-ltree

This is a demo that explores LTREEs with Hasura.

LTREEs are one method for querying hierarchical data models.

## Motivation

There are many ways to build systems of hierarchy. The advantage of LTREEs is that they simplify _ancestor path hierarchical queries_, but they come at some other costs, like not being immune to the _hierarchy reorganization problem_.

Because of Hasura's support for LTREEs, they seem like a compelling path.

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
pkgx task sql:create
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

## Further Reading

- [Recursive Queries in PostgreSQL for Hierarchical Data](https://indrajith.me/posts/recursive-queries-in-postgresql-for-hierarchial-data/)
- [Postgres Recursive Query(CTE) or Recursive Function?](https://medium.com/swlh/postgres-recursive-query-cte-or-recursive-function-3ea1ea22c57c)
- [Modeling Hierarchical Tree Data in PostgreSQL](https://leonardqmarcq.com/posts/modeling-hierarchical-tree-data)
- [Wikipedia — Nested set model](https://en.wikipedia.org/wiki/Nested_set_model)
