import "@babel/polyfill";
import CopyWebpackPlugin from "copy-webpack-plugin";
import DynamicCdnWebpackPlugin from "dynamic-cdn-webpack-plugin";
import ManifestPlugin from 'webpack-manifest-plugin';
import path from "path";

export default async function (_, { _mode }) {
  // We'll set up some paths for our generated files and our development server
  const staticDir = path.join(__dirname, ".");
  const destDir = path.join(__dirname, "../priv/static");
  const publicPath = "/";

  return {
    entry: [
      staticDir + "/js/app.js",
      // staticDir + "/css/app.scss"
    ],

    output: {
      path: destDir,
      filename: "js/app.js",
      publicPath
    },

    performance: {
      maxEntrypointSize: 5120000,
      maxAssetSize: 5120000
    },

    module: {
      rules: [
        {
          test: /\.jsx?$/,
          exclude: /(node_modules|bower_components)/,
          loader: "babel-loader",
          options: {
            babelrc: true,
          },
        },
        {
          test: /\.(graphql|gql)$/,
          exclude: /node_modules/,
          loader: 'graphql-tag/loader',
        },
      ]
    },

    plugins: [
      // We copy our images and fonts to the output folder
      new CopyWebpackPlugin([{ from: "./static/images", to: "images" }]),
      new ManifestPlugin({ fileName: 'manifest.json' }),
      new DynamicCdnWebpackPlugin({
        // verbose: true,
      })
    ],
  }
}
