import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'flow_widgets.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) => FlowScaffold(
        title: 'Services',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          flowTitle('What do you need help with?', 'Browse trusted services available in your area.'),
          Expanded(child: GridView.count(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.35, children: const [
            _Category('Plumbing', Icons.plumbing_rounded), _Category('Electrical', Icons.electrical_services_rounded), _Category('Cleaning', Icons.cleaning_services_rounded), _Category('Painting', Icons.format_paint_rounded), _Category('Carpentry', Icons.carpenter_rounded), _Category('Appliance repair', Icons.settings_suggest_rounded),
          ])),
        ]),
      );
}
class _Category extends StatelessWidget { const _Category(this.label, this.icon); final String label; final IconData icon; @override Widget build(BuildContext c)=>AppCard(onTap:()=>c.push('/services?category=$label'),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:30,color:AppTheme.primaryEmerald),const SizedBox(height:10),Text(label,textAlign:TextAlign.center)])); }
