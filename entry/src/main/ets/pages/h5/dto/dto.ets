/**
 * Author: user
 * Date: 2024/11/05
 * Modify: 2024/11/05
 * Desc: 数据类型
 */

/**
 *
 */
export interface PhotoOptions {
  watermark?: boolean;
  text?: string;
  mode?: number;
}
/**
 *
 */
export interface MediaOptions {
  type?: Array<number>;
  count?: number;
  upload?: boolean;
}
/**
 *
 */
export interface EmitterOptions {
  event?: string;
  data?: string;
}