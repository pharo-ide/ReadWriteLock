baselines
baseline: spec
	<baseline>
	spec for: #'common' do: [
		spec 
			package: 'ReadWriteLock';
			package: 'ReadWriteLock-Tests' with: [spec requires: #(ReadWriteLock)].
		spec 
			group: 'Core' with: #('ReadWriteLock');
			group: 'Tests' with: #('ReadWriteLock-Tests'). ].