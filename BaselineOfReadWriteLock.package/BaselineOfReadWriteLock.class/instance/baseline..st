baselines
baseline: spec
	<baseline>
	spec for: #'common' do: [
		spec baseline: 'StateSpecs' with: [
			spec repository: 'github://dionisiydk/StateSpecs:v2.4.10' ].
		spec 
			package: 'ReadWriteLock';
			package: 'ReadWriteLock-Tests' with: [spec requires: #(ReadWriteLock StateSpecs)].
		spec 
			group: 'Core' with: #('ReadWriteLock');
			group: 'Tests' with: #('ReadWriteLock-Tests'). ].
