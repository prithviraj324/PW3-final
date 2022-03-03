import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:TimeTrack/l10n.dart';
import 'package:TimeTrack/screens/export/ExportScreen.dart';
import 'package:TimeTrack/screens/projects/ProjectsScreen.dart';
import 'package:TimeTrack/screens/reports/ReportsScreen.dart';
import 'package:TimeTrack/screens/settings/SettingsScreen.dart';

enum MenuItem {
  projects,
  reports,
  export,
  settings,
}

class PopupMenu extends StatelessWidget {
  const PopupMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItem>(
      key: Key("menuButton"),
      icon: SvgPicture.asset(
        "icon.no-bg.svg",
        height: 30,
        semanticsLabel: L10N.of(context).tr.logoSemantics,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      onSelected: (MenuItem item) {
        switch (item) {
          case MenuItem.projects:
            Navigator.of(context).push(MaterialPageRoute<ProjectsScreen>(
              builder: (BuildContext _context) => ProjectsScreen(),
            ));
            break;
          case MenuItem.reports:
            Navigator.of(context).push(MaterialPageRoute<ReportsScreen>(
              builder: (BuildContext _context) => ReportsScreen(),
            ));
            break;
          case MenuItem.export:
            Navigator.of(context).push(MaterialPageRoute<ExportScreen>(
              builder: (BuildContext _context) => ExportScreen(),
            ));
            break;
          case MenuItem.settings:
            Navigator.of(context).push(MaterialPageRoute<SettingsScreen>(
              builder: (BuildContext _context) => SettingsScreen(),
            ));
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            key: Key("menuProjects"),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.layerGroup),
              title: Text(L10N.of(context).tr.projects),
            ),
            value: MenuItem.projects,
          ),
          PopupMenuItem(
            key: Key("menuReports"),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.chartPie),
              title: Text(L10N.of(context).tr.reports),
            ),
            value: MenuItem.reports,
          ),
          PopupMenuItem(
            key: Key("menuExport"),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.fileExport),
              title: Text(L10N.of(context).tr.export),
            ),
            value: MenuItem.export,
          ),
          PopupMenuItem(
            key: Key("menuSettings"),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.screwdriver),
              title: Text(L10N.of(context).tr.settings),
            ),
            value: MenuItem.settings,
          ),
          PopupMenuItem(
            key: Key("menuAbout"),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.dna),
              title: Text(L10N.of(context).tr.about),
            ),
            //value: MenuItem.about,
          ),
        ];
      },
    );
  }
}
