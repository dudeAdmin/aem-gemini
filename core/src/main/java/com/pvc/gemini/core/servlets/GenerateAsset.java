
package com.pvc.gemini.core.servlets;

import java.io.IOException;

import javax.servlet.Servlet;
import javax.servlet.ServletException;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.servlets.HttpConstants;
import org.apache.sling.api.servlets.SlingAllMethodsServlet;
import org.apache.sling.servlets.annotations.SlingServletResourceTypes;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.propertytypes.ServiceDescription;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pvc.gemini.core.service.GenAiService;



@Component(
    service = Servlet.class,
    property = {
        "sling.servlet.paths=/bin/pvc-gemini/generate-asset",
        "sling.servlet.methods=POST"
    }
)
@ServiceDescription("Generate Asset Servlet")
public class GenerateAsset extends SlingAllMethodsServlet  {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LoggerFactory.getLogger(GenerateAsset.class);
    
    @Reference
    private GenAiService genAiService;

    @Override
	protected void doPost(final SlingHttpServletRequest req, final SlingHttpServletResponse resp)
			throws ServletException, IOException {
    	try {
    		logger.info("GenerateAsset servlet called");
            genAiService.callGeminiApi(req, resp);
        } catch (Exception e) {
            logger.error("Error in GenerateAsset servlet", e);
            resp.setStatus(SlingHttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"success\":false,\"error\":\"" + e.getMessage() + "\"}");
        }
	}
}
