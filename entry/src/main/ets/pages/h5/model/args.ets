/**
 * Author: Meng
 * Date: 2024/11/05
 * Modify: 2024/11/05
 * Desc: 数据类型
 */

/**
 * 相机
 */
export interface CameraArg {
  content?: Record<string, string|number|boolean>;
  mode?: number; // 0照片；1视频; 2视频或图片
  position?: number; // 1后置,2前置
  // data?: Record<string, string|number|boolean>;
}

/**
 *
 */
export interface MediaArg {
  mode?: Array<number>; // 文件类型 1word;2ppt;3execl;4pdf
  count?: number;
  upload?: boolean;
  content?: Record<string, string|number|boolean>;
}

/**
 *
 */
export interface PhotoArg {
  count?: number;
  upload?: boolean;
  mode?: number; // 0图片；1视频；2视频和图片
  content?: Record<string, string|number|boolean>;
}

/**
 *
 */
export interface EmitArg {
  once?: boolean;
  mode?: boolean;
  time?: number; // 时间戳
  key?: string; // 标识
  event: string; // 事件
  data?: string | Record<string, string|number|boolean>; // 参数
}

export interface AudioArg {}

export interface PlayArg {}

export interface PreviewArg {
  type?: string;
  data?: Array<string>;
  index?: number;
}

export interface FolderArg {}

export interface SettingArg {
  package: string;
}

export interface LinkArg {
  package: string;
  params?: string | Record<string, string|number|boolean>;
}

export interface LocationArg {
  high?: boolean;
}

export interface ShareArg {
  data: Array<ShareItem>;
  title?: string;
}

export interface ShareItem {
  mold: number; // 1链接；2图片；2小程序；3微信
  openId?: string; // 原始id,
  appId?: string;
  title?: string;
  desc?: string; // 描述
  image?: string; // 封面cover
  path?: string;
  url?: string;
  scene?: string;
  ticket?: string;
  /** 0: 正式, 1: 测试, 2: 体验 */
  env?: 0 | 1 | 2;
}

export interface PageArg {
  theme?: string;
  title?: string;
  hide?: boolean;
  canBack?: boolean;
  bg?: string|Color;
  actions?: Array<ActionItem>;
}

export interface ActionItem {
  text?: string;
  icon?: string;
  key?: string;
  tag?: string;
  fontWeight?: number;
  color?: string|Color;
}

export interface RouteArg {
  path: string;
  params?: string | Record<string, string|number|boolean>;
}

export interface PayArg {
  payId?: string;
  orderId?: string;
}

export interface NavArg {
  lat: number;
  lng: number;
  name: string;
  address?: string;
}

