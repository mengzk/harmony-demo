/**
 * Author: Meng
 * Date: 2024/11/05
 * Modify: 2024/11/05
 * Desc: 数据类型
 */

export interface Latlng {
  code?: number;
  latitude: number;
  longitude: number;
  speed?: number; // 速度 m/s
  altitude?: number; // 高度
  accuracy?: number; // 精度 单位米
  address?: string;
  name?: string;
}

export interface DeviceDto {
  width: number;
  height: number;
  safeTop: number;
  safeBottom: number;
  model: string;
  deviceName: string;
  systemName: string;
  os: number;
  version: number;
  appVersion: string;
  uniqueId: string;
}
export interface AppDto {
  version: string;
  env?: string;
}
export interface UserDto {
  oneId?: string;
  userId?: string;
  userName?: string;
  token?: string;
  phone?: string;
  roles?: string;
}

export interface MediaDto {
  data?: Array<string | FileDto>;
  code?: number;
}

export interface FileDto {
  url?: string;
  path?: string;
  name?: string;
  suffix?: string; // 文件后缀
}

export interface UploadDto {
  code: number;
  msg: string;
  data?: string;
  list?: Array<string>;
}

export interface EmitDto {
  tag?: string|number;
  key: string;
  data?: Record<string, string|number|boolean>;
}