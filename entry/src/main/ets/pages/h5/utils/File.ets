/**
 * Author: Meng
 * Date: 2024/11/09
 * Modify: 2024/11/09
 * Desc:
 */
import { fileIo as fs } from '@kit.CoreFileKit';

export function copyFileToCache(path: string): string {
  const name = path.substring(path.lastIndexOf('/'));
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