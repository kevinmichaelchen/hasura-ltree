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
