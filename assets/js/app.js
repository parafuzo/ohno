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
      <Admin dataProvider={dataProvider} title="Ohno">
        <Resource name="Repository" list={RepositoryList} />
      </Admin>
    );
  }
}

ReactDOM.render(
  <App />,
  document.getElementById("root")
);
