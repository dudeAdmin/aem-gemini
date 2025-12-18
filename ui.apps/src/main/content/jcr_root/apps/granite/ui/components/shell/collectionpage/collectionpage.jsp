<%--
  ADOBE CONFIDENTIAL
  ___________________

  Copyright 2015 Adobe
  All Rights Reserved.

  NOTICE: All information contained herein is, and remains
  the property of Adobe and its suppliers, if any. The intellectual
  and technical concepts contained herein are proprietary to Adobe
  and its suppliers and are protected by all applicable intellectual
  property laws, including trade secret and copyright laws.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe.
--%><%
%><%@ include file="/libs/granite/ui/global.jsp" %><%
%><%@ page import="java.io.UnsupportedEncodingException,
                  java.io.IOException,
                  java.net.URLDecoder,
                  java.net.URLEncoder,
                  java.security.MessageDigest,
                  java.security.NoSuchAlgorithmException,
                  java.util.Arrays,
                  java.util.ArrayList,
                  java.util.Base64,
                  java.util.Collection,
                  java.util.Iterator,
                  java.util.Map,
                  java.util.List,
                  java.util.stream.Collectors,
                  javax.servlet.http.Cookie,
                  org.apache.commons.collections4.IteratorUtils,
                  org.apache.commons.lang3.StringUtils,
                  org.apache.jackrabbit.api.security.user.Authorizable,
                  org.apache.jackrabbit.util.Text,
                  org.apache.sling.api.SlingHttpServletRequest,
                  org.apache.sling.commons.json.JSONObject,
                  org.apache.sling.commons.json.io.JSONStringer,
                  org.apache.sling.commons.json.io.JSONWriter,
                  org.apache.sling.resourcemerger.api.ResourceMergerService,
                  com.adobe.granite.i18n.LocaleUtil,
                  com.adobe.granite.security.user.UserProperties,
                  com.adobe.granite.security.user.UserPropertiesManager,
                  com.adobe.granite.security.user.UserPropertiesService,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.ExpressionHelper,
                  com.adobe.granite.ui.components.ExpressionResolver,
                  com.adobe.granite.omnisearch.api.core.OmniSearchService,
                  com.adobe.granite.ui.components.FilteringResourceWrapper,
                  com.adobe.granite.ui.components.Tag,
                  com.adobe.granite.ui.components.Value" %><%--###
CollectionPage
==============

.. granite:servercomponent:: /libs/granite/ui/components/shell/collectionpage

   The page to render collection pattern.

   It also supports :doc:`resource filtering using FilteringResourceWrapper </jcr_root/libs/granite/ui/docs/server/resourcehiding>` and acts as its container.

   It has the following content structure:

   .. gnd:gnd::

      [granite:ShellCollectionPage]

      /**
       * A general purpose ID to uniquely identify the console.
       *
       * The recommended value is hierarchical separated by "-".
       * e.g. "cq-commerce-report"
       */
      - consoleId (StringEL)

      /**
       * The base title of the page.
       *
       * e.g. "AEM Sites"
       */
      - jcr:title (String)

      /**
       * The URI Template of the page. It is used to generate the new URL when navigating the collection.
       *
       * It supports the following variables:
       *
       *    id
       *       The id of the collection (:doc:`[data-foundation-collection-id] </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/vocabulary/collection>`).
       *
       * e.g. ``/sites.html{+id}``
       */
      - pageURITemplate (StringEL)

      /**
       * This property is the equivalence of ``pageURITemplate`` for absolute path.
       *
       * For example if your template is ``{+id}.html``, since it is not starting with "/",
       * the server is unable to know if it is an absolute path.
       * So use this property if you want to add the context path regardless.
       */
      - 'pageURITemplate.abs' (StringEL)

      /**
       * The value of :doc:`[data-foundation-mode-group] </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/vocabulary/mode>`
       * that the collection is part of.
       */
      - modeGroup (String)

      /**
       * The selector to the collection.
       */
      - targetCollection (String)

      /**
       * The path to the omnisearch configuration associated with the console.
       *
       * e.g. ``/libs/granite/omnisearch/content/metadata/site``
       */
      - omnisearchLocationPath (StringEL)

      /**
       * The URI Template of the preview of the selected items.
       * If this property is specified, an additional preview container is added.
       *
       * It supports the following variables:
       *
       * item
       *    The id of the selected item. (:doc:`[data-foundation-collection-item-id] </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/vocabulary/collection>`)
       *    Note that this variable can be a list of items.
       *
       * For example, if ``item = ("item1", "item2")`` and ``itemPreviewSrc = /preview{?item*}``, the final URI will be ``/preview?item=item1&item=item2``.
       */
      - itemPreviewSrc

      /**
       * To redirect the page, this resource can be specified.
       * It will be included, where the redirect can be performed.
       */
      + redirector

      /**
       * A folder to specify the content of ``<head>`` of the page.
       * Its child resources are iterated and included as is.
       */
      + head

      /**
       * The folder for the available views (i.e. the rendering) of the collection,
       * where each can any component implementing :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/vocabulary/collection`.
       *
       * At least one view needs to be provided.
       * If there are at least two views, the following properties are needed to be able to switch the view:
       *
       * icon (String)
       *    The icon of the view.
       * jcr:title (String)
       *    The title of the view.
       * src (StringEL)
       *    The URI Template that is returning the HTML response of the new view.
       *    It supports the following variables:
       *
       *    offset
       *       The item offset of the current request.
       *    limit
       *       The item limit of the pagination.
       *    id
       *       The id of the collection (:doc:`[data-foundation-collection-id] </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/vocabulary/collection>`).
       *
       * **View Settings**
       *
       * Each view is able to provide settings related to that view.
       * To do this, ``settings`` component needs to be specified. The component can be a container that contains the form fields representing the settings.
       * The form will be automatically generated, and the settings are saved in the user preferences.
       */
      + views mandatory

      /**
       * The header area just above the collection view.
       * Any component can be used here.
       */
      + header

      /**
       * The footer area just below the collection view.
       * Any component can be used here.
       */
      + footer

      + breadcrumbs

      /**
       * The component to render the title.
       *
       * Either this resource or ``breadcrumbs`` needs to be specified.
       * Use this resource instead of ``breadcrumbs`` when your resource is flat (not hierarchical).
       * If neither is specified, the value of ``jcr:title`` is used.
       *
       * If the title is just a simple string, :doc:`../title/index` can be used.
       *
       * The only requirement of the component is to generate a simple text without any wrapping markup.
       * E.g. To have a title of "My Page", just make the component do something like ``out.print("My Page")``.
       */
      + title

      /**
       * The folder for the actions applicable in the context of the collection.
       */
      + actions (granite:ShellCollectionPageActions)

      /**
       * A folder to specify the panels of the rail.
       */
      + rails (granite:ShellCollectionPageRails)

      [granite:ShellCollectionPageActions]

      /**
       * The folder for primary actions.
       *
       * The action can be any action component such as :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/button/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/anchorbutton/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/pulldown/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/collection/index`.
       *
       * The ``actionBar`` variant of the components above SHOULD be used, unless ``primary`` variant is used.
       *
       * Usually the action is implementing :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/collection/action/index`,
       * with ``relScope`` = ``collection``.
       *
       * The actions are wrapped inside :doc:`.foundation-collection-actionbar </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/collection/action/index>`
       * element where ``[data-foundation-collection-actionbar-target]`` is set as the value of ``targetCollection`` property.
       * This way setting the ``target`` property at individual action is not required.
       */
      + primary

      /**
       * The folder for secondary actions.
       *
       * The action can be any action component such as :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/button/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/anchorbutton/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/pulldown/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/collection/index`.
       *
       * The ``actionBar`` variant of the components above SHOULD be used, unless ``primary`` variant is used.
       *
       * Usually the action is implementing :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/collection/action/index`,
       * with ``relScope`` = ``collection``.
       *
       * The actions are wrapped inside :doc:`.foundation-collection-actionbar </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/collection/action/index>`
       * element where ``[data-foundation-collection-actionbar-target]`` is set as the value of ``targetCollection`` property.
       * This way setting the ``target`` property at individual action is not required.
       */
      + secondary

      /**
       * The folder for actions applicable during selection mode. (e.g. when one of the collection item is selected)
       *
       * The action can be any action component such as :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/button/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/anchorbutton/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/pulldown/index`,
       * :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/collection/index`.
       *
       * The ``actionBar`` variant of the components above SHOULD be used, unless ``primary`` variant is used.
       *
       * Usually the action is implementing :doc:`/jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/collection/action/index`,
       * with ``relScope`` = ``item``.
       *
       * The actions are wrapped inside :doc:`.foundation-collection-actionbar </jcr_root/libs/granite/ui/components/coral/foundation/clientlibs/foundation/js/collection/action/index>`
       * element where ``[data-foundation-collection-actionbar-target]`` is set as the value of ``targetCollection`` property.
       * This way setting the ``target`` property at individual action is not required.
       */
      + selection

      [granite:ShellCollectionPageRails]

      /**
       * ``true`` to activate the rail initially.
       *
       * Note that you need to also set ``active`` property of the rail panel to ``true`` accordingly.
       */
      - active (BooleanEL)

      /**
       * The child resources are considered as the panels, where each MUST be a :doc:`../../coral/foundation/panel/railpanel/index` (or its derivative).
       */
      + '*' (granite:PanelRailPanel)

   Example::

      + /apps/my/page
        - sling:resourceType = "granite/ui/components/shell/collectionpage"
        - jcr:title = "AEM Sites"
        - modeGroup = "cq-siteadmin-admin-childpages"
        - pageURITemplate = "/sites.html{+id}"
        - targetCollection = "#cq-siteadmin-admin-childpages"
        + views
          + card
            - sling:resourceType = "my/card"
            - granite:id = "cq-siteadmin-admin-childpages"
            - icon = "viewCard"
            - jcr:title = "Card View"
            - modeGroup = "cq-siteadmin-admin-childpages"
            - src = "/mnt/overlay/my/page/views/card{.offset,limit}.html{+id}"
            - offset = "${requestPathInfo.selectors[0]}"
            - limit = "${empty requestPathInfo.selectors[1] ? "20" : requestPathInfo.selectors[1]}"
            - path = "${requestPathInfo.suffix}"
            + settings
              - sling:resourceType = "granite/ui/components/coral/foundation/container"
              + items
                + field1
                  - sling:resourceType = "my/field"
                + field2
                  - sling:resourceType = "my/field"
          + list
            - sling:resourceType = "my/list"
            - granite:id = "cq-siteadmin-admin-childpages"
            - icon = "viewList"
            - jcr:title = "List View"
            - modeGroup = "cq-siteadmin-admin-childpages"
            - src = "/mnt/overlay/my/page/views/list{.offset,limit}.html{+id}"
            - offset = "${requestPathInfo.selectors[0]}"
            - limit = "${empty requestPathInfo.selectors[1] ? "20" : requestPathInfo.selectors[1]}"
            - path = "${requestPathInfo.suffix}"
###--%><%

Config cfg = cmp.getConfig();
ExpressionHelper ex = cmp.getExpressionHelper();

if (!cfg.get("noMerge", false)) {
    ResourceMergerService resourceMerger = sling.getService(ResourceMergerService.class);
    if (resourceMerger != null) {
        Resource uiResource = resourceMerger.getMergedResource(resource);
        if (uiResource != null) {
            resource = uiResource;
            cfg = new Config(resource);
        }
    }
}

resource = new FilteringResourceWrapper(resource, sling.getService(ExpressionResolver.class), slingRequest);

Resource redirector = resource.getChild("redirector");
if (redirector != null) {
    %><sling:include resource="<%= redirector %>" /><%

    if (response.isCommitted()) {
        return;
    }
}

String targetCollection = cfg.get("targetCollection", String.class);
String consoleId = StringUtils.trimToNull(ex.getString(cfg.get("consoleId", String.class)));

// GRANITE-8258: Force the header to bypass the compatibility mode on intranet sites
response.setHeader("X-UA-Compatible", "IE=edge");

AttrBuilder htmlAttrs = new AttrBuilder(request, xssAPI);
htmlAttrs.addClass("skipCoral2Validation");
htmlAttrs.add("lang", LocaleUtil.toRFC4646(request.getLocale()).toLowerCase());
htmlAttrs.add("data-i18n-dictionary-src", request.getContextPath() + "/libs/cq/i18n/dict.{+locale}.json");

%><!DOCTYPE html>
<html <%= htmlAttrs %>>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="shortcut icon" href="<%= request.getContextPath() %>/libs/granite/core/content/login/favicon.ico"><%

    String origTitle = cfg.get("jcr:title", String.class);
    String baseTitle = i18n.getVar(origTitle);
    String title = baseTitle;
    if (baseTitle != null) {
        String breadcrumbTitle = getBreadcrumbActiveItemTitle(resource, cmp);
        if (!breadcrumbTitle.isEmpty()) {
            // Expand the base title with the navigator/breadcrumb active element title.
            title = breadcrumbTitle + " | " + title;
        }

        String pageURITemplate = handleURITemplate(cfg, "pageURITemplate", ex, request);

        AttrBuilder titleAttrs = new AttrBuilder(request, xssAPI);
        titleAttrs.addClass("granite-collection-pagetitle");
        titleAttrs.add("data-granite-collection-pagetitle-target", targetCollection);
        titleAttrs.add("data-granite-collection-pagetitle-src", pageURITemplate);
        titleAttrs.add("data-granite-collection-pagetitle-base", baseTitle);

        %><title <%= titleAttrs %>><%= xssAPI.encodeForHTML(title) %></title><%
    }

    String[] pageHierarchy = getPageHierarchy(consoleId);

    if (pageHierarchy == null) {
        pageHierarchy = getPageHierarchyByTitle(!StringUtils.isBlank(origTitle) ? origTitle : resource.getPath());
    }

    String assetId = StringUtils.isNotEmpty(request.getParameter("item"))
        ? request.getParameter("item")
        : slingRequest.getRequestPathInfo().getSuffix();

    JSONObject trackingPage = new JSONObject();
    trackingPage.put("type", "collection");
    trackingPage.put("hierarchy", pageHierarchy[0]);
    trackingPage.put("name", pageHierarchy[1]);
    if (StringUtils.isNotEmpty(assetId)) {
        trackingPage.put("assetId", assetId);
    }

    %><meta name="foundation.tracking.page" content="<%= xssAPI.encodeForHTMLAttr(trackingPage.toString()) %>"><%

    Resource globalHead = resourceResolver.getResource("/mnt/overlay/granite/ui/content/globalhead");
    if (globalHead != null) {
        for (Iterator<Resource> it = globalHead.listChildren(); it.hasNext();) {
            %><sling:include resource="<%= it.next() %>" /><%
        }
    }

    Authorizable auth = resourceResolver.adaptTo(Authorizable.class);
    UserPropertiesManager upm = resourceResolver.adaptTo(UserPropertiesManager.class);
    UserProperties userPreferences = upm.getUserProperties(auth, UserPropertiesService.PREFERENCES_PATH);
    String userPreferencesPath = auth.getPath() + "/" + UserPropertiesService.PREFERENCES_PATH;
    String onboardingSrcPath = "/mnt/overlay/granite/ui/content/shell/onboarding.html";

    %><%-- <meta name="granite.shell.showonboarding"> is deprecated, use foundation-preference instead --%>
    <meta name="granite.shell.showonboarding" content="<%= xssAPI.encodeForHTMLAttr(getPreference(userPreferences, "granite.shell.showonboarding620", "true")) %>">
    <meta class="granite-shell-onboarding-src" data-granite-shell-onboarding-src="<%= xssAPI.getValidHref(request.getContextPath() + onboardingSrcPath) %>"><%

    AttrBuilder userPrefAttrs = new AttrBuilder(request, xssAPI);
    userPrefAttrs.add("name", "user.preferences");
    userPrefAttrs.add("content", getPreferencesJSON(userPreferences));
    userPrefAttrs.addHref("data-foundation-preference-action", userPreferencesPath);

    %><meta <%= userPrefAttrs %>>
    <%-- <meta name="user.preferences.winmode"> is deprecated, use foundation-preference instead --%>
    <meta name="user.preferences.winmode" content="<%= xssAPI.encodeForHTMLAttr(getPreference(userPreferences, "winMode", "multi")) %>"><%

    if (cfg.get("coral2", false)) {
        %><ui:includeClientLib categories="coralui2,granite.ui.coral.foundation,granite.ui.coral.foundation.addon.coral2,granite.ui.shell" /><%
    } else {
        %><ui:includeClientLib categories="coralui3,granite.ui.coral.foundation,granite.ui.shell" /><%
    }

    %><meta class="granite-omnisearch-src"
            data-granite-omnisearch-src="<%= xssAPI.getValidHref(request.getContextPath() + "/mnt/overlay/granite/ui/content/shell/omnisearch.html") %>"
            data-granite-omnisearch-search-url="<%= xssAPI.getValidHref(request.getContextPath() + "/aem/search.html") %>"><%

    Resource omnisearchConfigResource = resourceResolver.getResource(ex.getString(cfg.get("omnisearchLocationPath", String.class)));
    if (omnisearchConfigResource != null) {
        OmniSearchService omnisearchService = sling.getService(OmniSearchService.class);
        // check if OmnisearchHanlder is present
        if (omnisearchService.getModuleConfiguration(resourceResolver, omnisearchConfigResource.getName()) != null) {

            ValueMap props = omnisearchConfigResource.getValueMap();

            %><meta class="granite-omnisearch-location"
                    data-granite-omnisearch-location-value="<%= xssAPI.encodeForHTMLAttr(omnisearchConfigResource.getName()) %>"
                    data-granite-omnisearch-location-label="<%= xssAPI.encodeForHTMLAttr(i18n.getVar(props.get("jcr:title", ""))) %>"><%
        }
    }

    Resource head = resource.getChild("head");
    if (head != null) {
        for (Iterator<Resource> it = head.listChildren(); it.hasNext();) {
            %><sling:include resource="<%= it.next() %>" /><%
        }
    }
%></head><%
// Flush head so that the browser can start downloading the clientlibs
response.flushBuffer();

String modeGroup = cfg.get("modeGroup", String.class);

String navigationId = consoleId;

if (consoleId == null) {
    consoleId = generateConsoleId(resource);
}

String targetViewName = getTargetViewName(slingRequest, consoleId);

List<Resource> viewCache = new ArrayList<Resource>();
Resource currentView = null;

{
    int i = 0;
    for (Iterator<Resource> it = resource.getChild("views").listChildren(); it.hasNext(); i++) {
        Resource item = it.next();

        if (i == 0 || item.getName().equals(targetViewName)) {
            currentView = item;
        }

        viewCache.add(item);
    }
}

JSONWriter cookieConfig = new JSONStringer()
    .object()
        .key("name").value(consoleId)
        .key("expires").value(7)
        .key("path").value(request.getContextPath() + "/")
    .endObject();

JSONWriter availableSettings = new JSONStringer().array();
for (Resource view : viewCache) {
    if (view.getChild("settings") != null) {
        availableSettings.value(view.getName());
    }
}
availableSettings.endArray();

AttrBuilder viewAttrs = new AttrBuilder(request, xssAPI);
viewAttrs.addClass("coral--light");
viewAttrs.addClass("shell-collectionpage-view");
viewAttrs.add("data-shell-collectionpage-view-target", targetCollection);
viewAttrs.add("data-shell-collectionpage-view-cookie", cookieConfig.toString());
viewAttrs.add("data-shell-collectionpage-view-layoutId", currentView == null ? null : currentView.getName());
viewAttrs.add("data-shell-collectionpage-view-settings", availableSettings.toString());

Resource rails = resource.getChild("rails");
String railSaveKey = "rail-" + consoleId;
String railWidthSaveKey = "rail-width-" + consoleId;
String savedRailTarget = getCookie(slingRequest, railSaveKey);
String savedRailWidth = getCookie(slingRequest, railWidthSaveKey);
boolean savedRailTargetFound = false;
boolean hasActiveRail = rails != null && cmp.getExpressionHelper().getBoolean(rails.getValueMap().get("active", "false"));

String collectionWidthSaveKey = "collection-width-" + consoleId;
String savedCollectionWidth = getCookie(slingRequest, collectionWidthSaveKey);

Resource columnViewItem = resource.getChild("views").getChild("column");
Config columnViewItemCfg = new Config(columnViewItem);
String rootPath = ex.getString(columnViewItemCfg.get("rootPath", ""));

String itemPreviewSrc = handleURITemplate(cfg, "itemPreviewSrc", ex, request);

int minContentSize = 100;

// Even if no rails are configured, we need to add them when the columnview is enabled to add the tree
final boolean hasRails = rails != null || (columnViewItem != null && !rootPath.isEmpty());

%><body <%= viewAttrs %>>
<%
    Resource skipNavigationLinksRes = resource.getChild("skipnavigationlinks");
    if (skipNavigationLinksRes != null) {
        %><sling:include resource="<%= skipNavigationLinksRes %>" /><%
    }
%>
<coral-shell>
    <coral-shell-header class="coral--dark granite-shell-header"
        data-granite-shell-header-mode-group="<%= xssAPI.encodeForHTMLAttr(modeGroup) %>"
        role="region" aria-label="<%= xssAPI.encodeForHTMLAttr(i18n.get("Header Bar")) %>">
        <sling:call script="header.jsp"/>
    </coral-shell-header>

    <coral-shell-content role="main">
        <div id="granite-shell-content" class="foundation-layout-panel">
            <div class="foundation-layout-panel-header"><%
                AttrBuilder actionBarAttrs = new AttrBuilder(request, xssAPI);
                actionBarAttrs.add("id", "granite-shell-actionbar");
                actionBarAttrs.addClass("foundation-collection-actionbar");
                actionBarAttrs.add("data-foundation-collection-actionbar-target", targetCollection);

                %><betty-titlebar <%= actionBarAttrs %>>
                    <betty-titlebar-title><%
                        Resource breadcrumbs = resource.getChild("breadcrumbs");
                        if (breadcrumbs != null) {
                            List<Resource> crumbs = IteratorUtils.toList(cmp.asDataSource(breadcrumbs).iterator());

                            if (!crumbs.isEmpty()) {
                                AttrBuilder navigatorAttrs = new AttrBuilder(request, xssAPI);
                                navigatorAttrs.addClass("granite-collection-navigator");
                                navigatorAttrs.add("id", "granite-collection-breadcrumbs-toggle");
                                navigatorAttrs.add("trackingfeature", "aem:collectionpage");
                                navigatorAttrs.add("trackingelement", "breadcrumbs");
                                navigatorAttrs.add("data-granite-collection-navigator-target", targetCollection);

                                %><betty-breadcrumbs <%= navigatorAttrs %>><%
                                    for (int j = 0; j < crumbs.size(); j++) {
                                        Resource item = (Resource) crumbs.get(j);
                                        Config itemCfg = new Config(item);

                                        AttrBuilder itemAttrs = new AttrBuilder(request, xssAPI);
                                        String navigatorCollectionid = itemCfg.get("path", String.class);
                                        if (navigatorCollectionid != null) {
                                            itemAttrs.add("data-granite-collection-navigator-collectionid", navigatorCollectionid);
                                        } else {
                                            itemAttrs.add("data-granite-collection-navigator-href", itemCfg.get("href", String.class));
                                        }
                                        %><betty-breadcrumbs-item <%= itemAttrs %>><%= xssAPI.encodeForHTML(itemCfg.get("title")) %></betty-breadcrumbs-item><%
                                    }
                                %></betty-breadcrumbs><%
                            }
                        } else {
                            Resource titleRes = resource.getChild("title");
                            if (titleRes != null) {
                                %><span class="granite-title" role="heading" aria-level="1"><sling:include resource="<%= titleRes %>" /></span><%
                            } else {
                                %><span class="granite-title" role="heading" aria-level="1"><%= xssAPI.encodeForHTML(baseTitle) %></span><%
                            }
                        }
                    %></betty-titlebar-title>
                    <betty-titlebar-primary><%
                        if (hasRails) {
                                %>
                                <label id="cyclebutton-rail-toggle-label" for="shell-collectionpage-rail-toggle" class="u-coral-screenReaderOnly"><%= xssAPI.encodeForHTML(i18n.get("Open left rail for additional features")) %></label>
                                <coral-cyclebutton id="shell-collectionpage-rail-toggle"
                                                     class="granite-toggleable-control"
                                                     displaymode="icontext"
                                                     icon="railLeft"
                                                     threshold="1"
                                                     trackingfeature="aem:collectionpage"
                                                     aria-labelledby="cyclebutton-rail-toggle-label"
                                                     trackingelement="rail"
                                                     data-granite-toggleable-control-savekey="<%= xssAPI.encodeForHTMLAttr(railSaveKey) %>">
                                    <coral-cyclebutton-item
                                        displaymode="icon"
                                        trackingelement="contentonly"
                                        data-foundation-command="`"
                                        data-granite-toggleable-control-name="content-only"
                                        data-granite-toggleable-control-target="#shell-collectionpage-rail"
                                        data-granite-toggleable-control-action="hide"><%= xssAPI.encodeForHTML(i18n.get("Content Only")) %></coral-cyclebutton-item><%

                                    int railItemIndex = 1;
                                    if (columnViewItem != null && !rootPath.isEmpty()) {
                                        AttrBuilder navigationAttrs = new AttrBuilder(request, xssAPI);
                                        navigationAttrs.add("trackingelement", "contenttree");
                                        navigationAttrs.add("data-granite-toggleable-control-action", "show");
                                        navigationAttrs.add("data-granite-toggleable-control-name", "content-tree");
                                        navigationAttrs.add("data-foundation-command", "alt+" + railItemIndex++);
                                        navigationAttrs.add("data-granite-toggleable-control-target", ".shell-collectionpage-rail-panel[data-shell-collectionpage-rail-panel='content-tree']");

                                        if (!hasActiveRail && savedRailTarget != null && savedRailTarget.equals("content-tree")) {
                                            navigationAttrs.addSelected(true);
                                            savedRailTargetFound = true;
                                        }
                                        %><coral-cyclebutton-item <%= navigationAttrs %>><%= xssAPI.encodeForHTML(i18n.get("Content Tree")) %></coral-cyclebutton-item><%
                                    }
                                    if (rails != null) {
                                        // we map all rail items to the numbers in the keyboard using control + {index}
                                        for (Iterator<Resource> it = rails.listChildren(); it.hasNext(); railItemIndex++) {
                                            Resource item = it.next();

                                            if (cmp.getRenderCondition(item, true).check()) {
                                                Config itemCfg = new Config(item);
                                                AttrBuilder itemAttrs = new AttrBuilder(request, xssAPI);

                                                // we stop once we reach 9 since all available numbers have been used
                                                if (railItemIndex < 10) {
                                                    itemAttrs.add("data-foundation-command", "alt+" + railItemIndex);
                                                }

                                                itemAttrs.add("trackingelement", item.getName());
                                                itemAttrs.add("data-granite-toggleable-control-name", item.getName());

                                                if (item.getName().equals("omnisearchfilter")) {
                                                    itemAttrs.add("data-granite-toggleable-control-action", "hide");
                                                    itemAttrs.add("data-granite-toggleable-control-target", "#shell-collectionpage-rail");
                                                    itemAttrs.add("data-granite-omnisearch-filter", targetCollection);
                                                } else {
                                                    String href = ex.getString(itemCfg.get("href", String.class));

                                                    itemAttrs.add("icon", itemCfg.get("icon", String.class));

                                                    if (href != null) {
                                                        itemAttrs.add("data-granite-toggleable-control-action", "navigate");
                                                        itemAttrs.addHref("data-granite-toggleable-control-href", href);
                                                    } else {
                                                        String railPanelTarget = ".shell-collectionpage-rail-panel[data-shell-collectionpage-rail-panel='" + item.getName() + "']";

                                                        itemAttrs.add("data-granite-toggleable-control-action", "show");
                                                        itemAttrs.add("data-granite-toggleable-control-target", railPanelTarget);
                                                    }

                                                    itemAttrs.addSelected(itemCfg.get("active", false));

                                                    if (!hasActiveRail && savedRailTarget != null && savedRailTarget.equals(item.getName())) {
                                                        itemAttrs.addSelected(true);
                                                        savedRailTargetFound = true;
                                                    }
                                                }

                                                %><coral-cyclebutton-item <%= itemAttrs %>><%= outVar(xssAPI, i18n, itemCfg.get("jcr:title", String.class)) %></coral-cyclebutton-item><%
                                            }
                                        }
                                    }
                                %></coral-cyclebutton><%
                        }

                        Resource primary = resource.getChild("actions/primary");
                        if (primary != null) {
                            for (Iterator<Resource> it = primary.listChildren(); it.hasNext();) {
                                Resource item = it.next();
                                %><sling:include resource="<%= item %>" /><%
                            }
                        }
                    %></betty-titlebar-primary>
                    <betty-titlebar-secondary><%
                        AttrBuilder selectAllAttrs = new AttrBuilder(request, xssAPI);
                        selectAllAttrs.addClass("foundation-collection-selectall");
                        selectAllAttrs.addClass("coral-Button--graniteActionBar");
                        selectAllAttrs.add("data-foundation-collection-selectall-target", targetCollection);
                        selectAllAttrs.add("data-foundation-command", "ctrl+a");
                        selectAllAttrs.add("trackingfeature", "aem:collectionpage");
                        selectAllAttrs.add("trackingelement", "selectall");
                        %><button is="coral-button" variant="quiet" icon="selectAll" <%= selectAllAttrs %>><%= xssAPI.encodeForHTML(i18n.get("Select All")) %></button><%

                        Resource secondary = resource.getChild("actions/secondary");
                        if (secondary != null) {
                            for (Iterator<Resource> it = secondary.listChildren(); it.hasNext();) {
                                Resource item = it.next();
                                if ("create".equals(item.getName())) {
                                    AttrBuilder createAttrs = new AttrBuilder(request, xssAPI);
                                    createAttrs.addClass("granite-collection-create");
                                    createAttrs.add("data-granite-collection-create-target", targetCollection);

                                    cmp.include(item, new Tag(createAttrs));
                                } else {
                                    AttrBuilder attrs = new AttrBuilder(request, xssAPI);
                                    attrs.add("data-shell-collection-target", targetCollection);
                                    attrs.add("data-shell-console-id", consoleId);
                                    cmp.include(item, new Tag(attrs));
                                }
                            }
                        }

                        if (viewCache.size() > 1) {%>
                        <label id="cyclebutton-switcher-toggle-label" for="granite-collection-switcher-toggle" class="u-coral-screenReaderOnly"><%= xssAPI.encodeForHTML(i18n.get("Switch display format and adjust display setting")) %></label><%
                            AttrBuilder switcherAttrs = new AttrBuilder(request, xssAPI);
                            switcherAttrs.addClass("granite-collection-switcher");
                            switcherAttrs.add("id", "granite-collection-switcher-toggle");
                            switcherAttrs.add("aria-labelledby", "cyclebutton-switcher-toggle-label");
                            switcherAttrs.add("data-granite-collection-switcher-target", targetCollection);

                            %><coral-cyclebutton <%= switcherAttrs %>><%
                                for (Resource item : viewCache) {
                                    Config itemCfg = new Config(item);

                                    String src = ex.getString(itemCfg.get("src", String.class));

                                    AttrBuilder itemAttrs = new AttrBuilder(request, xssAPI);
                                    itemAttrs.add("data-granite-collection-switcher-src", handleURITemplate(src, request));
                                    itemAttrs.add("icon", itemCfg.get("icon", String.class));
                                    itemAttrs.addSelected(item.getName().equals(currentView.getName()));

                                    %><coral-cyclebutton-item <%= itemAttrs %>><%= outVar(xssAPI, i18n, itemCfg.get("jcr:title", String.class)) %></coral-cyclebutton-item><%
                                }

                                if (!viewCache.isEmpty()) {
                                    String viewSettingsSrcBase = "/mnt/overlay/granite/ui/content/shell/collectionpage/viewsettings.html";
                                    String src = viewSettingsSrcBase + Text.escapePath(resource.getPath()) + "?targetCollection=" + Text.escape(targetCollection);

                                    AttrBuilder itemAttrs = new AttrBuilder(request, xssAPI);
                                    itemAttrs.addClass("granite-collection-switcher-settings");
                                    itemAttrs.addClass("foundation-toggleable-control");
                                    itemAttrs.add("icon", "gear");
                                    itemAttrs.addHref("data-foundation-toggleable-control-src", src);
                                    itemAttrs.add("data-foundation-toggleable-control-action", "show");
                                    itemAttrs.add("data-foundation-toggleable-control-cache", "false");

                                    %><coral-cyclebutton-action <%= itemAttrs %>><%= xssAPI.encodeForHTML(i18n.get("View Settings")) %></coral-cyclebutton-action><%
                                }
                            %></coral-cyclebutton><%
                        }
                    %></betty-titlebar-secondary>
                </betty-titlebar><%

                Resource header = resource.getChild("header");
                if (header != null) {
                    %><sling:include resource="<%= header %>" /><%
                }
            %></div>
            <div class="foundation-layout-panel-bodywrapper">
                <div class="foundation-layout-panel-body">
<coral-accordion>
  <coral-accordion-item>
    <coral-accordion-item-label>Generate Asset With Gemini</coral-accordion-item-label>
    <coral-accordion-item-content>
					<textarea id="image-gen-prompt" is="coral-textarea" placeholder="Enter your image generation prompt OR Select 4 input images with text prompt" name="image-gen-prompt" value="" style="width: 100%;"></textarea>
					  <br> 
					  <br>
					<coral-select id="aspect-ration" name="aspect-ration" placeholder="Select aspect ratio">
					  <coral-select-item>1:1</coral-select-item>
					  <coral-select-item>4:3</coral-select-item>
					  <coral-select-item>3:2</coral-select-item>
					  <coral-select-item>16:9</coral-select-item>
					  <coral-select-item selected>2:3</coral-select-item>
					</coral-select>
					<br>
					<br>
					<br>
					<coral-select id="output-format" placeholder="Select output format">
					  <coral-select-item selected>image/jpeg</coral-select-item>
					  <coral-select-item>image/png</coral-select-item>
					</coral-select>
					<br>
					<br>
					<button id="gen-image" is="coral-button" variant="primary" icon="imageAdd" iconsize="XS">
					Generate
					</button> 
					<coral-wait style="margin-top: 1%; margin-left: 1%;" id="generate-wait" class="u-coral-screenReaderOnly"></coral-wait>
				</coral-accordion-item-content>
  </coral-accordion-item>
</coral-accordion>
				<%
                    if (hasRails) {
                        AttrBuilder railAttrs = new AttrBuilder(request, xssAPI);
                        railAttrs.add("id", "shell-collectionpage-rail");
                        railAttrs.addClass("foundation-toggleable foundation-layout-panel-rail granite-rail");
                        railAttrs.addClass("foundation-container-resizable");
                        railAttrs.add("data-granite-layout-panel-save-key", railWidthSaveKey);
                        railAttrs.add("data-granite-layout-panel-min-width", 250);

                        String railStyle = null;
                        if (!StringUtils.isEmpty(savedRailWidth)) {
                            railStyle = "width: " + savedRailWidth + "px;";
                        }
                        if (savedRailTargetFound || (rails != null && cmp.getExpressionHelper().getBoolean(rails.getValueMap().get("active", "false")))) {
                            railAttrs.addClass("foundation-layout-panel-rail-active");
                            railAttrs.addClass("foundation-layout-panel-rail-activate-panel");
                        } else if (!StringUtils.isEmpty(savedRailWidth)) {
                            railStyle = railStyle + " margin-left: -" + savedRailWidth + "px;";
                        }
                        railAttrs.add("style", railStyle);

                        %><div <%= railAttrs %>>
                            <coral-panelstack maximized><%
                                if (rails != null) {
                                    for (Iterator<Resource> it = rails.listChildren(); it.hasNext();) {
                                        Resource item = it.next();

                                        AttrBuilder itemAttrs = new AttrBuilder(request, xssAPI);
                                        itemAttrs.addClass("shell-collectionpage-rail-panel");
                                        itemAttrs.add("data-shell-collectionpage-rail-panel", item.getName());

                                        if (!hasActiveRail && savedRailTarget != null && savedRailTarget.equals(item.getName())) {
                                            itemAttrs.addSelected(true);
                                        }

                                        cmp.include(item, new Tag(itemAttrs));
                                    }
                                }
                                if (columnViewItem != null && !rootPath.isEmpty()) {
                                    Resource columnRoot = resourceResolver.getResource(rootPath);
                                    String path = ex.getString(columnViewItemCfg.get("path", String.class));
                                    Resource currentColumnItem = resourceResolver.getResource(path);
                                    String src = request.getContextPath() + "/mnt/overlay/granite/ui/content/tree{.offset}.html{+id}?columnPath=" + Text.escapePath(columnViewItem.getPath());

                                    AttrBuilder navigationPanelItemAttrs = new AttrBuilder(request, xssAPI);
                                    navigationPanelItemAttrs.addClass("foundation-toggleable");
                                    navigationPanelItemAttrs.addClass("foundation-layout-panel-rail-panel");
                                    // navigationPanelItemAttrs.add("data-foundation-layout-panel-rail-panel-src",);
                                    navigationPanelItemAttrs.addClass("shell-collectionpage-rail-panel");
                                    navigationPanelItemAttrs.add("data-shell-collectionpage-rail-panel", "content-tree");

                                    if (!hasActiveRail && savedRailTarget != null && savedRailTarget.equals("content-tree")) {
                                        navigationPanelItemAttrs.addSelected(true);
                                    }

                                    AttrBuilder treeElemAttrs = new AttrBuilder(request, xssAPI);
                                    treeElemAttrs.add("class", "shell-collectionpage-tree");
                                    treeElemAttrs.add("data-shell-collectionpage-tree-target", targetCollection);
                                    treeElemAttrs.add("root-id", columnRoot.getPath());
                                    treeElemAttrs.add("src", src);
                                    treeElemAttrs.add("children", getChildrenJSON(currentColumnItem, columnRoot));
                                    treeElemAttrs.add("label", xssAPI.encodeForHTML(i18n.get("Content Tree")));

                                    %><coral-panel <%= navigationPanelItemAttrs %>>
                                        <foundation-tree <%= treeElemAttrs %>>
                                            <foundation-tree-loading><%= xssAPI.encodeForHTML(i18n.get("Loading content")) %></foundation-tree-loading>
                                            <foundation-tree-error><%= xssAPI.encodeForHTML(i18n.get("Could not load content")) %></foundation-tree-error>
                                            <foundation-tree-empty><%= xssAPI.encodeForHTML(i18n.get("There is no item")) %></foundation-tree-empty>
                                            <foundation-tree-load-more><%= xssAPI.encodeForHTML(i18n.get("Load more")) %></foundation-tree-load-more>
                                        </foundation-tree>
                                    </coral-panel><%
                                }
                            %></coral-panelstack>
                            <div class="foundation-container-resizable-handle"></div>
                        </div><%
                    }

	                Config currentViewCfg = new Config(currentView);
	                String selector = currentViewCfg.get("selector", String.class);

                	if (itemPreviewSrc != null) {
                        %><div class="foundation-layout-panel-content" data-granite-layout-content-min-width="<%= minContentSize %>">
                            <div class="foundation-layout-panel">
                                <div class="foundation-layout-panel-body"><%
                                    AttrBuilder collectionAttrs = new AttrBuilder(request, xssAPI);
                                    collectionAttrs.addClass("foundation-layout-panel-rail foundation-layout-panel-rail-active");
                                    collectionAttrs.addClass("foundation-container-resizable");
                                    collectionAttrs.add("data-granite-layout-panel-save-key", collectionWidthSaveKey);
                                    collectionAttrs.add("data-granite-layout-panel-min-width", 272);

                                    if (!StringUtils.isEmpty(savedCollectionWidth)) {
                                        collectionAttrs.add("style", "width: " + savedCollectionWidth + "px;");
                                    }

                                    %><div <%= collectionAttrs %>><%
                                        // Need to introduce `.foundation-layout-util-maximized-container` wrapper element to work around a bug
                                        // at `.foundation-container-resizable` which requires its child to be scrollable.
                                        AttrBuilder previewSupportAttrs = new AttrBuilder(request, xssAPI);
                                        previewSupportAttrs.addClass("foundation-layout-util-maximized-container");
                                        previewSupportAttrs.addClass("foundation-collection-previewsupport");
                                        previewSupportAttrs.add("data-foundation-collection-previewsupport-collection", "child");
                                        previewSupportAttrs.add("data-foundation-collection-previewsupport-target", "#granite-shell-collection-preview");
                                        previewSupportAttrs.add("data-foundation-collection-previewsupport-src", itemPreviewSrc);

                                        %><div <%= previewSupportAttrs %>><%
                                            if (StringUtils.isNotEmpty(selector)) {
                                                %><sling:include resource="<%= currentView %>" addSelectors="<%= selector %>" /><%
                                            } else {
                                                %><sling:include resource="<%= currentView %>" /><%
                                            }
                                        %></div>
                                        <div class="foundation-container-resizable-handle"></div>
                                    </div>
                                    <div id="granite-shell-collection-preview" class="foundation-layout-panel-content" data-granite-layout-content-min-width="<%= minContentSize %>"></div>
                                </div>
                            </div>
                        </div><%
                    } else {
                        // Note that `.foundation-collection-content` is not needed and can be removed.
                        // However, there is a bad selector using it in Assets code base right now.
                        %><div class="foundation-layout-panel-content foundation-collection-content" data-granite-layout-content-min-width="<%= minContentSize %>"><%
                            if (StringUtils.isNotEmpty(selector)) {
                                %><sling:include resource="<%= currentView %>" addSelectors="<%= selector %>" /><%
                            } else {
                                %><sling:include resource="<%= currentView %>" /><%
                            }
                        %></div><%
                    }
                %></div>
            </div><%

            Resource footer = resource.getChild("footer");
            if (footer != null) {
                %><div class="foundation-layout-panel-footer">
                    <sling:include resource="<%= footer %>" />
                </div><%
            }
        %></div>
    </coral-shell-content>
</coral-shell><%

AttrBuilder selectionAttrs = new AttrBuilder(request, xssAPI);
selectionAttrs.addClass("granite-collection-selectionbar");
selectionAttrs.addClass("foundation-mode-switcher");
selectionAttrs.add("data-foundation-mode-switcher-group", modeGroup);

%><div <%= selectionAttrs %>>
    <div class="foundation-mode-switcher-item" data-foundation-mode-switcher-item-mode="selection"><%
        AttrBuilder selectionBarAttrs = new AttrBuilder(request, xssAPI);
        selectionBarAttrs.addClass("betty-ActionBar betty-ActionBar--large");
        selectionBarAttrs.addClass("foundation-collection-actionbar");
        selectionBarAttrs.add("data-foundation-collection-actionbar-target", targetCollection);
        selectionBarAttrs.add("role", "region");
        selectionBarAttrs.add("aria-label", i18n.get("Action Bar"));
        %><coral-actionbar <%= selectionBarAttrs %>>
            <coral-actionbar-primary><%
                Resource selection = resource.getChild("actions/selection");
                if (selection != null) {
                    for (Iterator<Resource> it = selection.listChildren(); it.hasNext();) {
                        Resource item = it.next();

                        if (!cmp.getRenderCondition(item, true).check()) {
                            continue;
                        }
                        %><coral-actionbar-item><%
                            AttrBuilder selectionItemAttrs = new AttrBuilder(request, xssAPI);
                            selectionItemAttrs.addClass("betty-ActionBar-item");
                            cmp.include(item, new Tag(selectionItemAttrs));
                        %></coral-actionbar-item><%
                    }
                }
            %></coral-actionbar-primary>
            <coral-actionbar-secondary>
                <coral-actionbar-item><%
                    AttrBuilder deselectAttrs = new AttrBuilder(request, xssAPI);
                    deselectAttrs.add("is", "coral-button");
                    deselectAttrs.add("variant", "quiet");
                    deselectAttrs.add("type", "button");
                    deselectAttrs.add("icon", "close");
                    deselectAttrs.add("iconposition", "right");
                    deselectAttrs.add("iconsize", "S");
                    deselectAttrs.addClass("betty-ActionBar-item");
                    deselectAttrs.addClass("granite-collection-deselect");
                    deselectAttrs.add("data-granite-collection-deselect-target", targetCollection);
                    deselectAttrs.add("data-foundation-command", "escape");
                    deselectAttrs.add("data-granite-collection-deselect-template", i18n.get("Remove {0} selected items", null, "{{count}}"));

                    AttrBuilder counterAttrs = new AttrBuilder(request, xssAPI);
                    counterAttrs.addClass("foundation-admin-selectionstatus");
                    counterAttrs.add("data-foundation-admin-selectionstatus-template", i18n.get("{0} selected", null, "{{count}}"));
                    counterAttrs.add("data-foundation-admin-selectionstatus-target", targetCollection);

                    %><button <%= deselectAttrs %>><span <%= counterAttrs %>></span></button>
                </coral-actionbar-item>
            </coral-actionbar-secondary>
        </coral-actionbar>
    </div>
</div>
<a class="foundation-toggleable-control u-coral-screenReaderOnly"
   aria-hidden="true"
   data-foundation-command="?"
   data-foundation-toggleable-control-src="<%= request.getContextPath() %>/mnt/overlay/granite/ui/content/shell/shortcutsdialog.html">
</a><%

Resource globalFooter = resourceResolver.getResource("/mnt/overlay/granite/ui/content/globalfooter");
if (globalFooter != null) {
    for (Iterator<Resource> it = globalFooter.listChildren(); it.hasNext();) {
        %><sling:include resource="<%= it.next() %>" /><%
    }
}
%>
<script>


function getSelectedAssets() {
  return $('coral-masonry-item.is-selected')
    .map(function () {
      return $(this).attr('data-foundation-collection-item-id');
    })
    .get();
}



var getCurrentFolderPath = function(){
	var fullPath = window.location.pathname;
	return fullPath.indexOf("assets.html") !== -1 ? fullPath.split('.html')[1] : "";
}

$(document).ready(function() { $('#gen-image').on('click', function(e) { 
	e.preventDefault();
	$('#generate-wait').removeClass("u-coral-screenReaderOnly");
debugger;
    var prompt = $('#image-gen-prompt').val();
    var aspectRatio = $('#aspect-ration coral-selectlist-item[selected]').text();
    var outputFormat = $('#output-format coral-selectlist-item[selected]').text();

    // Get selected assets from the UI (you'll need to implement this based on your asset selection mechanism)
    var selectedAssets = getSelectedAssets() || []; // Implement this function

    if (!prompt && selectedAssets.length === 0) {
        alert('Please enter a prompt or select input images');
        return;
    }
	var currentFolderPath = getCurrentFolderPath();
	if(!currentFolderPath){
		alert('Wrong folder');
        return;
	}

    var requestData = {
        prompt: prompt,
        aspectRatio: aspectRatio,
        outputFormat: outputFormat,
        imageFolderPath: currentFolderPath, // Implement this to get current DAM folder path
        inputImagePath1: selectedAssets[0] || '',
        inputImagePath2: selectedAssets[1] || '',
        inputImagePath3: selectedAssets[2] || '',
        inputImagePath4: selectedAssets[3] || ''
    };

    // Show loading indicator
    var $button = $(this);
    $button.attr('disabled', true);
    $button.find('coral-icon').attr('icon', 'spinner');

    $.ajax({
        url: '/bin/pvc-gemini/generate-asset',
        type: 'POST',
        data: requestData,
        contentType: 'application/x-www-form-urlencoded',
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                alert('Image generated successfully at: ' + response.path);
                // Refresh the DAM view or redirect
                location.reload();
            } else {
                alert('Error: ' + (response.message || response.error));
            }
        },
        error: function(xhr, status, error) {
            alert('Failed to generate image: ' + error);
        },
        complete: function() {
			$('#generate-wait').addClass("u-coral-screenReaderOnly");
            // Reset button state
            $button.attr('disabled', false);
            $button.find('coral-icon').attr('icon', 'imageAdd');
        }
    });
});
});
</script>
</body>
</html><%!

/**
 * Fetch the breadcrumb active item title.
 *
 * @return {String} - The active item title or en empty string.
 */
private String getBreadcrumbActiveItemTitle(Resource resource, ComponentHelper cmp) throws ServletException, IOException {
    String activeItemTitle = "";
    Resource breadcrumbs = resource.getChild("breadcrumbs");
    if (breadcrumbs != null) {
        List<Resource> crumbs = IteratorUtils.toList(cmp.asDataSource(breadcrumbs).iterator());
        // The item in position 0 is ignored as it represents the root item.
        if (crumbs.size() > 1) {
            Resource item = crumbs.get(0);
            Config itemCfg = new Config(item);
            activeItemTitle = itemCfg.get("title");
        }
    }

    return activeItemTitle;
}

private String getCookie(SlingHttpServletRequest request, String key) {
    try {
        Cookie cookie = request.getCookie(key);

        if (cookie == null) {
            return null;
        }

        return URLDecoder.decode(cookie.getValue(), "utf-8");
    } catch (UnsupportedEncodingException impossible) {
        throw new RuntimeException(impossible);
    }
}

private String getChildrenJSON(Resource current, Resource root) throws Exception {
    List<Resource> ancestors = getAncestors(current, root);

    JSONStringer json = new JSONStringer();

    json.array();

    for (Resource ancestor : ancestors) {
        json.object();
        json.key("id").value(ancestor.getPath());
        json.endObject();
    }

    json.object();
    json.key("id").value(current.getPath());
    json.endObject();

    json.endArray();

    return json.toString();
}

/**
 * Returns the ancestors of the current resource (exclusive) up to the root.
 * The result is ordered with the root as the first item.
 */
private List<Resource> getAncestors(Resource current, Resource root) {
    List<Resource> results = new ArrayList<Resource>();

    if (current == null || root == null || current.getPath().equals(root.getPath())) {
        return results;
    }

    Resource r = current.getParent();

    while (r != null) {
        if (r.getPath().equals(root.getPath())) {
            break;
        }

        results.add(0, r);
        r = r.getParent();
    }

    return results;
}

private String generateConsoleId(Resource resource) {
    try {
        MessageDigest md = MessageDigest.getInstance("md5");
        byte[] b = md.digest(resource.getPath().getBytes("utf-8"));
        return Base64.getUrlEncoder().encodeToString(b).substring(0, 22); // cut off last "==".
    } catch (NoSuchAlgorithmException impossible) {
        throw new RuntimeException(impossible);
    } catch (UnsupportedEncodingException impossible) {
        throw new RuntimeException(impossible);
    }
}

private String getTargetViewName(SlingHttpServletRequest request, String consoleId) {
    try {
        consoleId = URLEncoder.encode(consoleId, "utf-8");
        Cookie cookie = request.getCookie(consoleId);

        if (cookie == null) {
            return null;
        }

        return URLDecoder.decode(cookie.getValue(), "utf-8");
    } catch (UnsupportedEncodingException impossible) {
        throw new RuntimeException(impossible);
    }
}

private String handleURITemplate(String src, HttpServletRequest request) {
    if (src != null && src.startsWith("/")) {
        return request.getContextPath() + src;
    }
    return src;
}

private String handleURITemplate(Config cfg, String name, ExpressionHelper ex, HttpServletRequest request) {
    String value = ex.getString(cfg.get(name, String.class));

    if (value != null) {
        if (value.startsWith("/")) {
            return request.getContextPath() + value;
        } else {
            return value;
        }
    }

    value = ex.getString(cfg.get(name + ".abs", String.class));

    if (value != null) {
        return request.getContextPath() + value;
    } else {
        return value;
    }
}

private String getPreferencesJSON(UserProperties props) throws Exception {
    JSONStringer json = new JSONStringer();
    json.object();

    if (props != null) {
        for (String name : props.getPropertyNames()) {
            Object v = props.getProperty(name, null, Object.class); // No conversion, use Object.class
            if (v != null) {
                json.key(name).value(v);
            }
        }
    }

    json.endObject();
    return json.toString();
}

private String getPreference(UserProperties props, String name, String defaultValue) throws Exception {
    if (props != null) {
        return props.getProperty(name, defaultValue, String.class);
    } else {
        return defaultValue;
    }
}

/**
 * Return the hierarchy and name of the current page based on consoleId.
 *
 * If the first part of the consoleId is "cq" or "granite", the part is ignored.
 *
 * Example
 *
 * ----------------------------------------------
 * consoleId    | result
 * ----------------------------------------------
 * cq-sites     | hierarchy = sites, name = sites
 * cq-sites-abc | hierarchy = sites, name = abc
 * ----------------------------------------------
 */
private String[] getPageHierarchy(String consoleId) {
    if (StringUtils.isBlank(consoleId)) {
        return null;
    }

    String[] parts = consoleId.split("-");

    int startIndex = 0;

    String namespace = parts[0];
    if (namespace.equals("cq") || namespace.equals("granite")) {
        startIndex = 1;
    }

    if (startIndex >= parts.length) {
        return null;
    }

    String name = parts[parts.length - 1];

    String hierarchy;
    if (startIndex == parts.length - 1) {
        hierarchy = name;
    } else {
        hierarchy = StringUtils.join(parts, ':', startIndex, parts.length - 1);
    }

    return new String[] { hierarchy, name };
}

/**
 * Returns the hierarchy and name of the current page based on the title.
 */
private String[] getPageHierarchyByTitle(String title) {
    String[] parts = title.split("\\|");

    String namespace = parts[0];
    if (namespace.startsWith("AEM")) {
        parts[0] = namespace.replaceFirst("AEM", "");
    }

    String name = parts[parts.length - 1].trim().toLowerCase();

    String hierarchy;
    if (parts.length == 1) {
        hierarchy = name;
    } else {
    	hierarchy = Arrays.stream(parts)
            .limit(parts.length - 1)
            .map(String::trim)
            .map(String::toLowerCase)
            .collect(Collectors.joining(":"));
    }

    return new String[] { hierarchy, name };
}
%>
