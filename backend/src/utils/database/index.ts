import sql from 'mssql';
import { config } from '@/config';

/**
 * @summary Expected return types for database operations
 */
export enum ExpectedReturn {
  None = 'None',
  Single = 'Single',
  Multi = 'Multi',
}

/**
 * @summary Record set interface
 */
export interface IRecordSet<T = any> {
  recordset: T[];
  rowsAffected: number[];
}

/**
 * @summary Database connection pool
 */
let pool: sql.ConnectionPool | null = null;

/**
 * @summary Get database connection pool
 * @description Creates or returns existing connection pool
 *
 * @returns {Promise<sql.ConnectionPool>} Database connection pool
 */
export async function getPool(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config.database);
  }
  return pool;
}

/**
 * @summary Execute database stored procedure
 * @description Executes a stored procedure with parameters and returns results
 *
 * @param {string} routine Stored procedure name
 * @param {object} parameters Input parameters
 * @param {ExpectedReturn} expectedReturn Expected return type
 * @param {sql.Transaction} transaction Optional transaction
 * @param {string[]} resultSetNames Optional result set names
 *
 * @returns {Promise<any>} Query results
 */
export async function dbRequest(
  routine: string,
  parameters: any = {},
  expectedReturn: ExpectedReturn = ExpectedReturn.None,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> {
  try {
    const currentPool = await getPool();
    const request = transaction ? new sql.Request(transaction) : currentPool.request();

    Object.keys(parameters).forEach((key) => {
      request.input(key, parameters[key]);
    });

    const result = await request.execute(routine);

    switch (expectedReturn) {
      case ExpectedReturn.Single:
        return result.recordset[0] || null;

      case ExpectedReturn.Multi:
        if (resultSetNames && resultSetNames.length > 0) {
          const namedResults: { [key: string]: any } = {};
          resultSetNames.forEach((name, index) => {
            namedResults[name] = result.recordsets[index] || [];
          });
          return namedResults;
        }
        return result.recordsets;

      case ExpectedReturn.None:
      default:
        return result;
    }
  } catch (error: any) {
    console.error('Database request error:', {
      routine,
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
}

/**
 * @summary Begin database transaction
 * @description Creates a new database transaction
 *
 * @returns {Promise<sql.Transaction>} Database transaction
 */
export async function beginTransaction(): Promise<sql.Transaction> {
  const currentPool = await getPool();
  const transaction = new sql.Transaction(currentPool);
  await transaction.begin();
  return transaction;
}

/**
 * @summary Commit database transaction
 * @description Commits an active transaction
 *
 * @param {sql.Transaction} transaction Transaction to commit
 */
export async function commitTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.commit();
}

/**
 * @summary Rollback database transaction
 * @description Rolls back an active transaction
 *
 * @param {sql.Transaction} transaction Transaction to rollback
 */
export async function rollbackTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.rollback();
}

/**
 * @summary Close database connection pool
 * @description Closes the database connection pool
 */
export async function closePool(): Promise<void> {
  if (pool) {
    await pool.close();
    pool = null;
  }
}

export default {
  getPool,
  dbRequest,
  beginTransaction,
  commitTransaction,
  rollbackTransaction,
  closePool,
  ExpectedReturn,
};
