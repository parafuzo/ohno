import React from 'react';
import { List, Datagrid, TextField } from 'react-admin';

export const RepositoryList = (props) => (
  <List {...props}>
    <Datagrid>
      <TextField source="id" />
      <TextField source="github" />
    </Datagrid>
  </List>
);
