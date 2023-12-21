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
import type { SpaceGroup } from './SpaceGroup';
import { SpaceGroupFromJSON, SpaceGroupFromJSONTyped, SpaceGroupToJSON } from './SpaceGroup';

/**
 *
 * @export
 * @interface GetSpaceGroupListResponseData
 */
export interface GetSpaceGroupListResponseData {
  /**
   *
   * @type {number}
   * @memberof GetSpaceGroupListResponseData
   */
  total?: number;
  /**
   *
   * @type {Array<SpaceGroup>}
   * @memberof GetSpaceGroupListResponseData
   */
  items?: Array<SpaceGroup>;
}

/**
 * Check if a given object implements the GetSpaceGroupListResponseData interface.
 */
export function instanceOfGetSpaceGroupListResponseData(value: object): boolean {
  let isInstance = true;

  return isInstance;
}

export function GetSpaceGroupListResponseDataFromJSON(json: any): GetSpaceGroupListResponseData {
  return GetSpaceGroupListResponseDataFromJSONTyped(json, false);
}

export function GetSpaceGroupListResponseDataFromJSONTyped(
  json: any,
  ignoreDiscriminator: boolean,
): GetSpaceGroupListResponseData {
  if (json === undefined || json === null) {
    return json;
  }
  return {
    total: !exists(json, 'total') ? undefined : json['total'],
    items: !exists(json, 'items')
      ? undefined
      : (json['items'] as Array<any>).map(SpaceGroupFromJSON),
  };
}

export function GetSpaceGroupListResponseDataToJSON(
  value?: GetSpaceGroupListResponseData | null,
): any {
  if (value === undefined) {
    return undefined;
  }
  if (value === null) {
    return null;
  }
  return {
    total: value.total,
    items:
      value.items === undefined ? undefined : (value.items as Array<any>).map(SpaceGroupToJSON),
  };
}
