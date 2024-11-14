/**
 * Author: Meng
 * Date: 2024/11/05
 * Modify: 2024/11/05
 * Desc: 数据类型
 */

import File from "@system.file";


export interface Latlng {
  code?: number;
  lat: number;
  lng: number;
  speed?: number; // 速度 m/s
  altitude?: number; // 高度
  accuracy?: number; // 精度 单位米
  address?: string;
  name?: string;
}

export interface DeviceDto {
  deviceName?: string;
  width: number;
  height: number;
  top: number;
  bottom: number;
  // safeAreaTop: number;
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
  data?: Array<string | File>;
  code?: number;
}
