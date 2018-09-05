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
import "@babel/polyfill";

// import socket from "./socket"
import React from "react";
import ReactDOM from "react-dom";
import { Admin, Resource } from "react-admin";

import makeProvider from './data_provider';
import { RepositoryList } from "./repositories";

class App extends React.Component {
  constructor() {
    super();
    this.state = { dataProvider: null };
  }

  componentDidMount() {
    return makeProvider().then((dataProvider) => {
      this.setState({ dataProvider });
    });
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
