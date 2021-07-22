import { AWSPartitial } from '@libs/aws-partial';
import { handlerPath } from '@libs/handlerResolver';

export const todo: AWSPartitial = {
  resources: {
    Resources: {
      TodosTable: {
        Type: 'AWS::DynamoDB::Table',
        DeletionPolicy: 'Retain',
        Properties: {
          AttributeDefinitions: [
            {
              AttributeName: 'id',
              AttributeType: 'S',
            }
          ],
          KeySchema: [
            {
              AttributeName: 'id',
              KeyType: 'HASH',
            },
          ],
          BillingMode: 'PAY_PER_REQUEST',
          TableName: 'Todos-SLS-demo',
        },
      },
    }
  },
  functions: {
    createTodo: {
      handler: `${handlerPath(__dirname)}/handler.createTodo`,
      memorySize: 128,
      events: [
        {
          httpApi: {
            path: '/todo',
            method: 'post',
          },
        },
      ],
    },
    getTodos: {
      handler: `${handlerPath(__dirname)}/handler.getTodos`,
      memorySize: 128,
      events: [
        {
          httpApi: {
            path: '/todo',
            method: 'get',
          },
        },
      ],
    },
    getTodoById: {
      handler: `${handlerPath(__dirname)}/handler.getTodoById`,
      memorySize: 128,
      events: [
        {
          httpApi: {
            path: '/todo/{id}',
            method: 'get',
          },
        },
      ],
    },
    updateTodo: {
      handler: `${handlerPath(__dirname)}/handler.updateTodo`,
      memorySize: 128,
      events: [
        {
          httpApi: {
            path: '/todo/{id}',
            method: 'put',
          },
        },
      ],
    },
    deleteTodo: {
      handler: `${handlerPath(__dirname)}/handler.deleteTodo`,
      memorySize: 128,
      events: [
        {
          httpApi: {
            path: '/todo/{id}',
            method: 'delete',
          },
        },
      ],
    },

  }
};
