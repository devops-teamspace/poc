/* tslint:disable */
/* eslint-disable */
/**
 * Server API - Login
 * The Restful APIs of Login.
 *
 * The version of the OpenAPI document: 1.0.0
 *
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */

import { exists, mapValues } from '../runtime';
import type { CategoriesEnum } from './CategoriesEnum';
import {
  CategoriesEnumFromJSON,
  CategoriesEnumFromJSONTyped,
  CategoriesEnumToJSON,
} from './CategoriesEnum';
import type { UploadFile } from './UploadFile';
import { UploadFileFromJSON, UploadFileFromJSONTyped, UploadFileToJSON } from './UploadFile';

/**
 *
 * @export
 * @interface Asset
 */
export interface Asset {
  /**
   * asset id
   * @type {string}
   * @memberof Asset
   */
  id?: string;
  /**
   * asset tags
   * @type {Array<string>}
   * @memberof Asset
   */
  tags?: Array<string>;
  /**
   * asset type
   * @type {string}
   * @memberof Asset
   */
  type?: AssetTypeEnum;
  /**
   * asset category
   * @type {Array<CategoriesEnum>}
   * @memberof Asset
   */
  categories?: Array<CategoriesEnum>;
  /**
   * asset files information
   * @type {Array<UploadFile>}
   * @memberof Asset
   */
  files?: Array<UploadFile>;
  /**
   * asset created time
   * @type {Date}
   * @memberof Asset
   */
  createdAt?: Date;
  /**
   * asset updated time
   * @type {Date}
   * @memberof Asset
   */
  updatedAt?: Date;
}

/**
 * @export
 */
export const AssetTypeEnum = {
  Decoration: 'decoration',
} as const;
export type AssetTypeEnum = (typeof AssetTypeEnum)[keyof typeof AssetTypeEnum];

/**
 * Check if a given object implements the Asset interface.
 */
export function instanceOfAsset(value: object): boolean {
  let isInstance = true;

  return isInstance;
}

export function AssetFromJSON(json: any): Asset {
  return AssetFromJSONTyped(json, false);
}

export function AssetFromJSONTyped(json: any, ignoreDiscriminator: boolean): Asset {
  if (json === undefined || json === null) {
    return json;
  }
  return {
    id: !exists(json, 'id') ? undefined : json['id'],
    tags: !exists(json, 'tags') ? undefined : json['tags'],
    type: !exists(json, 'type') ? undefined : json['type'],
    categories: !exists(json, 'categories')
      ? undefined
      : (json['categories'] as Array<any>).map(CategoriesEnumFromJSON),
    files: !exists(json, 'files')
      ? undefined
      : (json['files'] as Array<any>).map(UploadFileFromJSON),
    createdAt: !exists(json, 'created_at') ? undefined : new Date(json['created_at']),
    updatedAt: !exists(json, 'updated_at') ? undefined : new Date(json['updated_at']),
  };
}

export function AssetToJSON(value?: Asset | null): any {
  if (value === undefined) {
    return undefined;
  }
  if (value === null) {
    return null;
  }
  return {
    id: value.id,
    tags: value.tags,
    type: value.type,
    categories:
      value.categories === undefined
        ? undefined
        : (value.categories as Array<any>).map(CategoriesEnumToJSON),
    files:
      value.files === undefined ? undefined : (value.files as Array<any>).map(UploadFileToJSON),
    created_at: value.createdAt === undefined ? undefined : value.createdAt.toISOString(),
    updated_at: value.updatedAt === undefined ? undefined : value.updatedAt.toISOString(),
  };
}
