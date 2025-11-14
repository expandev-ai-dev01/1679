import { z } from 'zod';

/**
 * @summary Common Zod validation schemas
 * @description Reusable validation schemas for common data types
 */

/**
 * @summary String validation
 */
export const zString = z.string().min(1);
export const zNullableString = (maxLength?: number) => {
  let schema = z.string();
  if (maxLength) {
    schema = schema.max(maxLength);
  }
  return schema.nullable();
};

/**
 * @summary Name validation
 */
export const zName = z.string().min(1).max(200);

/**
 * @summary Description validation
 */
export const zDescription = z.string().max(500);
export const zNullableDescription = z.string().max(500).nullable();

/**
 * @summary Foreign key validation
 */
export const zFK = z.number().int().positive();
export const zNullableFK = z.number().int().positive().nullable();

/**
 * @summary Bit/Boolean validation
 */
export const zBit = z.number().int().min(0).max(1);

/**
 * @summary Date validation
 */
export const zDate = z.date();
export const zDateString = z.string().datetime();

/**
 * @summary Numeric validation
 */
export const zNumeric = z.number();
export const zPositiveNumeric = z.number().positive();

/**
 * @summary Email validation
 */
export const zEmail = z.string().email().max(255);

/**
 * @summary ID validation
 */
export const zId = z.coerce.number().int().positive();

export default {
  zString,
  zNullableString,
  zName,
  zDescription,
  zNullableDescription,
  zFK,
  zNullableFK,
  zBit,
  zDate,
  zDateString,
  zNumeric,
  zPositiveNumeric,
  zEmail,
  zId,
};
