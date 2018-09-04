// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import React from "react";
import ReactDOM from "react-dom";
// import buildGraphQLProvider from 'ra-data-graphql-simple';
// import { HttpLink } from 'apollo-link-http';
// import ApolloClient from "apollo-boost";
// import { InMemoryCache } from 'apollo-cache-inmemory';
import { Admin, Resource } from "react-admin";
// import { ApolloProvider } from "react-apollo";

import { RepositoryList } from "./repositories";

class App extends React.Component {
  constructor() {
    super();
    this.state = { dataProvider: null };
  }

  componentDidMount() {
    // const client = new ApolloClient({
    //   uri: "/graphql",
    // });

    this.setState({
      dataProvider(...args) {
        console.log({ args });
        return {
          data: [{id: 1, github: "nuxlli/fabion"}],
          total: 1
        }
      }
    })
  }

  render() {
    const { dataProvider } = this.state;

    if (!dataProvider) {
      return <div>Loading</div>;
    }

    return (
      <Admin dataProvider={dataProvider}>
        <Resource name="Repository" list={RepositoryList} />
      </Admin>
    );
  }
}

ReactDOM.render(
  <App />,
  document.getElementById("root")
);
