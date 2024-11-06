/**
 * Author: user
 * Date: 2024/11/05
 * Modify: 2024/11/05
 * Desc: 数据类型
 */

/**
 * 相机
 */
export interface CameraArg {
  watermark?: boolean;
  text?: string;
  mode?: number; // 0前置；1后置
  type?: number; // 0照片；1视频
}
/**
 *
 */
export interface MediaArg {
  type?: Array<number>;
  count?: number;
  upload?: boolean;
}
/**
 *
 */
export interface PhotoArg {
  count?: number;
  upload?: boolean;
}
/**
 *
 */
export interface EmitArg {
  once?: boolean;
  key?: string;
  event?: string;
  data?: string|object;
}

export interface AudioArg {

}

export interface PlayArg {

}

export interface PreviewArg {
  type?: string;
  data?: Array<string>;
  index?: number;
}

export interface FolderArg {

}

export interface SettingArg {
  package: string;
}

export interface LinkArg {
  package: string;
  params?: string|Map<string, object>;
}

export interface LocationArg {
  high?: boolean;
}

export interface ShareArg {
  data: Array<ShareItem>;
  title?: string;
}

interface ShareItem {
  mold: number; // 1链接；2图片；2小程序；3微信
  key?: string; // 原始id,
  appId?: string;
  title?: string;
  desc?: string; // 描述
  cover?: string; // 封面
  url?: string;
}

export interface PageArg {
  title?: string;
  header?: boolean;
  bg?: Color;
  actions?: Array<ActionItem>;
}

interface ActionItem {
  text?: string;
  icon?: string;
}

export interface RouteArg {
  path: string;
  params?: string|object;
}
export interface PayArg {
  payId?: string;
  orderId?: string;
}

export interface NavArg {
  lat: number;
  lng: number;
  name: string;
}

