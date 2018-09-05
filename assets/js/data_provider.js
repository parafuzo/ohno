import ApolloClient from "apollo-boost";
import gql from "graphql-tag";
import R from "rambda/webVersion";

import RepositoriesQuery from '../../priv/queries/repositories.graphql';
import Fragments from '../../priv/queries/fragments.graphql';

let client = null;

export default async function makeProvider() {
  if (!client) {
    client = new ApolloClient({
      uri: "/graphql",
    });
  }

  return async (...args) => {
    const GET_REPOSITORIES = gql`
      ${RepositoriesQuery},
      ${Fragments}
    `;

    const result = await client.query({ query: GET_REPOSITORIES });
    const total = R.pathOr(0, 'data.repositories.totalCount', result);
    const data = R.pipe(
      R.pathOr([], 'data.repositories.edges'),
      (item) => { console.log({ item }); return item },
      R.map(({ node }) => node)
    )(result);

    return { data, total };
  };
}
