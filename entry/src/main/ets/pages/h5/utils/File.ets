/**
 * Author: Meng
 * Date: 2024/11/09
 * Modify: 2024/11/09
 * Desc:
 */
import { fileIo as fs } from '@kit.CoreFileKit';

import {axDownload} from './axios'
import {FileArg} from '../model/args'

/**
 * 复制文件到缓存
 * @param path
 * @returns
 */
export function copyFileToCache(path: string): string {
  let name = path.substring(path.lastIndexOf('/'));
  try {
    name = decodeURIComponent(name);
  } catch (err) {
    console.warn('------> copyFileToCache', JSON.stringify(err))
  }
  const fileDir = `${getContext().cacheDir}${name}`;

  let file = fs.openSync(path, fs.OpenMode.READ_ONLY);
  // let file2 = fs.openSync(fileDir, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE); //先创建有读写权限的文件，再把不可读写的文件复制过来
  // fs.copyFileSync(file.fd, file2.fd);
  fs.copyFileSync(file.fd, fileDir);

  // 关闭文件
  fs.closeSync(file);
  // fs.closeSync(file2);
  return fileDir;
}

/**
 * 保存文件到本地
 * @param url
 * @param dir
 * @param name
 */
export function saveFileToDisk(arg: FileArg) {
  const url = arg.url||"";
  const dir = arg.dir||"";
  const name = arg.name||"";
  if(url.includes('https://') || url.includes('http://')) {
    axDownload(url, dir, name);
  }else {

  }
}

/**
 * 读取本地文件
 * @param path
 * @param dir
 * @returns
 */
export function readFileFromDisk(arg: FileArg): string {
  const path = arg.path;
  // const cacheDir = getContext().cacheDir;
  let file = fs.openSync(path, fs.OpenMode.READ_WRITE);
  return '';
}