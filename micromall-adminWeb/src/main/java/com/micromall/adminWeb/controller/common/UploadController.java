package com.micromall.adminWeb.controller.common;

import com.micromall.adminWeb.controller.BaseController;
import com.micromall.datacenter.utils.UploadResourceServer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Administrator on 2015/5/19.
 */
@Controller
public class UploadController extends BaseController {
    @Autowired
    private UploadResourceServer resourceServer;

    @RequestMapping(value = "/upload", method = RequestMethod.POST)
    @ResponseBody
    public Map<Object, Object> upLoad(@RequestParam(value = "btnFile", required = false) MultipartFile files, HttpServletRequest request) {
        int result = 0;
        Map<Object, Object> responseData = new HashMap<Object, Object>();
        try {
            String path = request.getSession().getServletContext().getRealPath("/");
//            String orignalFile = files.getOriginalFilename();
//            String prefix = orignalFile.substring(orignalFile.lastIndexOf(".") + 1);
//            Date now = new Date();
//            String fileFolder = "/uploaded/image/" + getCustomerId() + "/" + StringUtil.DateFormat(now, "yyyyMMdd");
//            String fileName = StringUtil.DateFormat(now, "yyyyMMddHHmmSS") + "." + prefix;
//            File targetFile = new File(path + fileFolder, fileName);
//            if (!targetFile.getParentFile().exists()) {
//                targetFile.getParentFile().mkdirs();
//            }
//            files.transferTo(targetFile);
//
//            System.out.println(fileFolder + "/" + fileName);
            String token = resourceServer.saveResource(files.getInputStream(), path, files.getOriginalFilename(), getCustomerId());
            responseData.put("file", token);
            responseData.put("fileUri", resourceServer.resourceUri(token));
            result = 1;
        } catch (Exception e) {
            responseData.put("msg", e.getMessage());
        }
        responseData.put("result", result);

        return responseData;
    }
}
